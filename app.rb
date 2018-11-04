require 'bundler/setup'
Bundler.require
require 'sinatra'   # gem 'sinatra'
require 'json'
require 'line/bot'  # gem 'line-bot-api'
require 'dotenv'
require './models/marathon.rb'
require './models/runner.rb'
require './models/count.rb'
require './models/audience.rb'

Dotenv.load

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

get '/marathon' do
  @marathons = Marathon.all.to_json
end

post '/runner' do
  body = request.body.read
  if body == ''
    status 400
  else
    result = JSON.parse(body)
    Runner.create({
      name: result["name"],
      number: resukt["number"],

    })
    status 201
  end
end


post '/runner/:marathonId' do
  Rnner.where(params[:marathonId]).to_json
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)

  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        text = event["message"]["text"]
        if text == "登録"
          message = {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
                "type": "confirm",
                "text": "Are you audience or runner?",
                "actions": [
                    {
                      "type": "message",
                      "label": "audience",
                      "text": "audience"
                    },
                    {
                      "type": "message",
                      "label": "runner",
                      "text": "runner"
                    }
                ]
            }
          }
          client.reply_message(event['replyToken'], message)
        elsif text == "audience"
          @user_id = event["source"]["userId"]
          Audience.create(audience_line_id: @user_id)
        end
      end
    end
  }

  "OK"
end

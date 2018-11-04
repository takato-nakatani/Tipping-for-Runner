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
      number: result["number"],
      marathon_id: result["marathon_id"]
      runner_line_id: result["runner_line_id"]
    })
    status 201
  end
end


get '/runner/:marathonId' do
  Runner.where(params[:marathonId]).to_json
end

post '/line/push/:runnerId' do
  runner = Runner.find(params[:runnerId])
  body = request.body.read
  if body == ''
    status 400
  else
    result = JSON.parse(body)
    Counts.create({
      number: result[number],
      runner_line_id: runner.runner_line_id
      audience_line_id: result[audience_line_id],
    })
    message = "you're cheered by audience"
    notification = {
      type: "text",
      text: message,
    }
    client.push_message(runner.runner_line_id, notification)
    status 201
  end
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

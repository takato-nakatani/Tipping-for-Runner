require 'bundler/setup'
Bundler.require
require 'sinatra'   # gem 'sinatra'
require 'line/bot'  # gem 'line-bot-api'
require 'dotenv'
require 'net/http'
require 'uri'
require 'json'
require './models/marathon.rb'
require './models/runner.rb'
require './models/count.rb'
require './models/audience.rb'

Dotenv.load

reserve_ep = 'https://sandbox-api-pay.line.me/v2/payments/request'
push_ep = 'https://api.line.me/v2/bot/message/push'

# def callGetApi(endpoint)
#   uri = URI.parse(endpoint)
#   http = Net::HTTP.new(uri.host, uri.port)
#
#   http.use_ssl = true
#   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#
#   req = Net::HTTP::Get.new(uri.request_uri)
#   req["Content-Type"] = "application/json"
#   req["X-LINE-ChannelId"] = ENV["LINE_PAY_CHANNEL_ID"]
#   req["X-LINE-ChannelSecret"] = ENV["LINE_PAY_CHANNEL_SECRET_KEY"]
#   res = http.request(req)
#   puts res.code, res.msg
#   puts res.body
#   p api_response = JSON.parse(res.body)
# end

# LINEPAYに支払い予約を行うAPIを叩く
def callLinePayApi(endpoint)
  uri = URI.parse(endpoint)
  proxy_class = Net::HTTP::Proxy(ENV["LINE_PAY_HOST_NAME"], 80)
  http = proxy_class.new(uri.host, uri.port)

  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Post.new(uri.request_uri)
  req["Content-Type"] = "application/json"
  req["X-LINE-ChannelId"] = ENV["LINE_PAY_CHANNEL_ID"]
  req["X-LINE-ChannelSecret"] = ENV["LINE_PAY_CHANNEL_SECRET_KEY"]

  data = {
    productName: "投げ銭",
    amount: 1,
    currency: "JPY",
    orderId: 1,
    confirmUrl: ENV["LINE_PAY_CONFIRM_URL"],
    payType: "PREAPPROVED"
  }.to_json

  req.body = data
  res = http.request(req)
  res.body
  # puts res.code, res.msg, res.body
end

# Botにプッシュ通知を実行させるAPIを叩く
def callPushApi(endpoint)
  uri = URI.parse(endpoint)
  http = Net::HTTP.new(uri.host, uri.port)

  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Post.new(uri.request_uri)
  req["Content-Type"] = "application/json"
  req["Authorization"] = "Bearer #{ENV["LINE_CHANNEL_TOKEN"]}"

  data =
  {
    "to": "Uf3851702d78351c34d914308064c090c",
    "messages":[
        {
            "type":"text",
            "text":"you're cheered by audience"
        }
    ]
  }.to_json

  req.body = data
  res = http.request(req)
  puts res.code, res.msg, res.body
end

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
      marathon_id: result["marathon_id"],
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
      runner_line_id: runner.runner_line_id,
      audience_line_id: result[audience_line_id]
    })
    callPushApi(push_ep)
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
        if text == "チョコレート"
          data = callLinePayApi(reserve_ep)
          result = JSON.parse(data)
          message = {
            "type": "template",
            "altText": "チョコレートを購入するには下記のボタンで決済に進んでください",
            "template": {
                "type": "buttons",
                "text": "チョコレートを購入するには下記のボタンで決済に進んでください?",
                "actions": [
                    {
                      "type": "uri",
                      "label": "LINE Payで決済",
                      "uri": result["info"]["paymentUrl"]["web"]
                    },
                ]
            }
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    end
  }

  "OK"
end

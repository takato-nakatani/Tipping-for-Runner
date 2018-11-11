require 'bundler/setup'
Bundler.require
require 'sinatra'   # gem 'sinatra'
require 'sinatra/reloader'
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

get '/' do
  request.host
end

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
def callLinePayApi(endpoint, count)

  uri = URI.parse(endpoint)
  req = Net::HTTP::Post.new(uri.request_uri)
  line_pay_confirm_url = 'https://' + request.host + '/pay/confirm'
  req["Content-Type"] = "application/json"
  req["X-LINE-ChannelId"] = ENV["LINE_PAY_CHANNEL_ID"]
  req["X-LINE-ChannelSecret"] = ENV["LINE_PAY_CHANNEL_SECRET_KEY"]

  data = {
    productName: "投げ銭",
    amount: count,
    currency: "JPY",
    orderId: 1,
    confirmUrl: line_pay_confirm_url,
    payType: "PREAPPROVED"
  }.to_json

  req.body = data

  #proxyを設定
  _, username, password, host, port = ENV["LINE_PAY_HOST_NAME"].gsub(/(:|\/|@)/,' ').squeeze(' ').split
  http = Net::HTTP.new(uri.host, uri.port, host, port, username, password)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  #リクエスト送信
  res = http.request(req)
  res.body
end


# Botにプッシュ通知を実行させるAPIを叩く
def pushToRunner(endpoint, runner_line_id)
  uri = URI.parse(endpoint)
  http = Net::HTTP.new(uri.host, uri.port)

  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Post.new(uri.request_uri)
  req["Content-Type"] = "application/json"
  req["Authorization"] = "Bearer #{ENV['LINE_CHANNEL_TOKEN_TKT']}"
  
  data =
  {
    "to": runner_line_id,
    "messages":[
        {
            "type":"text",
            "text":"you're cheered by audience"
        },
        {
            "type": "sticker",
            "packageId": "2",
            "stickerId": "166"
        }
    ]
  }.to_json

  req.body = data
  res = http.request(req)
  puts res.code, res.msg, res.body
end

def pushToAudience(endpoint, audience_line_id, web_uri)
  uri = URI.parse(endpoint)
  http = Net::HTTP.new(uri.host, uri.port)

  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Post.new(uri.request_uri)
  req["Content-Type"] = "application/json"
  req["Authorization"] = "Bearer #{ENV['LINE_CHANNEL_TOKEN_TKT']}"
  data =
  {
    "to": audience_line_id,
    "messages":[{
      "type": "template",
      "altText": "投げ銭をするには下記のボタンで決済に進んでください",
      "template": {
          "type": "buttons",
          "text": "投げ銭をするには下記のボタンで決済に進んでください?",
          "actions": [
              {
                "type": "uri",
                "label": "LINE Payで決済",
                "uri": web_uri
              },
          ]
      }
    }]
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

# マラソン情報を取得するためのエンドポイント
get '/marathon' do
  @marathons = Marathon.all.to_json
end

# ランナーが登録するときのPOSTリクエストのエンドポイント
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

# 観客がマラソンIDを指定した際にそのマラソンに出ているマラソンランナーを取得
get '/runner/:marathonId' do
  Runner.where(params[:marathonId]).to_json
end

# ランナーを指定して、観客から応援を送るときのエンドポイント
post '/line/push/:runnerId' do
  runner = Runner.find(params[:runnerId])
  body = request.body.read
  if body == ''
    status 400
  else
    result = JSON.parse(body)

    Count.create({
      number: result["number"],
      runner_line_id: runner.runner_line_id,
      audience_line_id: result["audience_line_id"]
    })

    pushToRunner(push_ep, runner.runner_line_id)
    data = callLinePayApi(reserve_ep, result["number"])
    res = JSON.parse(data)
    pushToAudience(push_ep, result["audience_line_id"], res["info"]["paymentUrl"]["web"])
    status 201
  end
end

# 決済完了の処理を行うエンドポイント
get '/pay/confirm' do
  messages = [{
            type: "sticker",
            packageId: 2,
            stickerId: 144
        },{
            type: "text",
            text: "ありがとうございます、投げ銭の決済が完了しました。"
        }]
  # 下記コードを観客に送れるようにする。
  # client.push_message(ENV["LINE_ID"], messages)
  "ありがとうございます、投げ銭の決済が完了しました。"
end

# ラインのwebhookに登録しているエンドポイント
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
          data = callLinePayApi(reserve_ep, 5)
          result = JSON.parse(data)
          message = {
            "type": "template",
            "altText": "チョコレートを購入するには下記のボタンで決済に進んでください",
            "template": {
                "type": "buttons",
                "text": "チョコレートを購入するには下記のボタンで決済に進んでください",
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
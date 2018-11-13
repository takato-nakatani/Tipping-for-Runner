require 'bundler/setup'
#Bundler.require
# require 'sinatra'   # gem 'sinatra'
# require 'line/bot'  # gem 'line-bot-api'
require 'dotenv'
require 'net/https'
require 'uri'
require 'json'

# require './models/marathon.rb'
# require './models/runner.rb'
# require './models/count.rb'
# require './models/audience.rb'

Dotenv.load

inquiry_ep = 'https://sandbox-api-pay.line.me/v2/payments'
reserve_ep = 'https://sandbox-api-pay.line.me/v2/payments/request'
confirm_ep = 'https://sandbox-api-pay.lone.me/v2/payments/{transactionId}/confirm'
continuation_ep = 'https://sandbox-api-pay.lone.me/v2/payments/preapprovedPay/{regKey}/payment'
push_ep = 'https://api.line.me/v2/bot/message/push'

def callGetApi(endpoint)
  uri = URI.parse(endpoint)
  http = Net::HTTP.new(uri.host, uri.port)

  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Get.new(uri.request_uri)
  req["Content-Type"] = "application/json"
  req["X-LINE-ChannelId"] = ENV["LINE_PAY_CHANNEL_ID"]
  req["X-LINE-ChannelSecret"] = ENV["LINE_PAY_CHANNEL_SECRET_KEY"]
  res = http.request(req)
  puts res.code, res.msg
  puts res.body
  p api_response = JSON.parse(res.body)
end

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
    "to": ENV["LINE_ID"],
    "messages":[
        {
            "type":"text",
            "text":"Hello, world1"
        },
        {
            "type":"text",
            "text":"Hello, world2"
        }
    ]
  }.to_json

  req.body = data
  res = http.request(req)
  puts res.code, res.msg, res.body
end

def callLinePayApi(endpoint, count)

  uri = URI.parse(endpoint)
  req = Net::HTTP::Post.new(uri.request_uri)
  req["Content-Type"] = "application/json"
  req["X-LINE-ChannelId"] = ENV["LINE_PAY_CHANNEL_ID"]
  req["X-LINE-ChannelSecret"] = ENV["LINE_PAY_CHANNEL_SECRET_KEY"]

  data = {
    productName: "投げ銭",
    amount: count,
    currency: "JPY",
    orderId: 1,
    confirmUrl: ENV["LINE_PAY_CONFIRM_URL"],
    payType: "PREAPPROVED"
  }.to_json

  req.body = data
  p req
  #proxyを設定
  _, username, password, host, port = ENV["LINE_PAY_HOST_NAME"].gsub(/(:|\/|@)/,' ').squeeze(' ').split
  http = Net::HTTP.new(uri.host, uri.port, host, port, username, password)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  #リクエスト送信
  res = http.request(req)
  res.body
end

def postApi(endpoint)
  uri = URI.parse(endpoint)
  http = Net::HTTP.new(uri.host, uri.port)

  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Post.new(uri.request_uri)

  data =
  {
    "number": "5",
    "runner_line_id": ENV["LINE_AT_ID"],
    "audience_line_id": ENV["LINE_ID"]
  }.to_json

  req.body = data
  res = http.request(req)
  puts res.code, res.msg, res.body
end

def postRunner(endpoint)
  uri = URI.parse(endpoint)
  http = Net::HTTP.new(uri.host, uri.port)

  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Post.new(uri.request_uri)

  data =
  {
    "name": "ベンチャー",
    "number": 5,
    "marathon_id": 1,
    "runner_line_id": ENV["LINE_AT_ID"]
  }.to_json

  req.body = data
  res = http.request(req)
  puts res.code, res.msg, res.body
end

#postRunner('https://bb139998.ngrok.io/runner')
postApi('https://bb139998.ngrok.io/line/push/3')

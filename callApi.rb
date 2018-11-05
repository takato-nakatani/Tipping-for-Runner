require 'bundler/setup'
#Bundler.require
# require 'sinatra'   # gem 'sinatra'
# require 'line/bot'  # gem 'line-bot-api'
require 'dotenv'
require 'net/https'
require 'uri'
require 'json'
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
    "to": "Uf3851702d78351c34d914308064c090c",
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

_, username, password, host, port = ENV["FIXIE_URL"].gsub(/(:|\/|@)/,' ').squeeze(' ').split
uri       = URI("http://welcome.usefixie.com")
request   = Net::HTTP.new(uri.host, uri.port, host, port, username, password)
response  = request.get(uri)

require 'bundler/setup'
#Bundler.require
# require 'sinatra'   # gem 'sinatra'
# require 'line/bot'  # gem 'line-bot-api'
require 'dotenv'
require 'net/https'
require 'uri'
require 'json'
Dotenv.load

confirm_ep = 'https://sandbox-api-pay.line.me/v2/payments'

uri = URI.parse(confirm_ep)
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
# def client
#   @client ||= Line::Bot::Client.new { |config|
#     config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
#     config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
#   }
# end
#
# post '/callback' do
#   body = request.body.read
#
#   signature = request.env['HTTP_X_LINE_SIGNATURE']
#   unless client.validate_signature(body, signature)
#     error 400 do 'Bad Request' end
#   end
#
#   events = client.parse_events_from(body)
#
#   events.each { |event|
#     case event
#     when Line::Bot::Event::Message
#       case event.type
#       when Line::Bot::Event::MessageType::Text
#         message = {
#           type: 'text',
#           text: event.message['text']
#         }
#         client.reply_message(event['replyToken'], message)
#       end
#     end
#   }
#
#   "OK"
# end

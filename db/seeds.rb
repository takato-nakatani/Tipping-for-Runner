# encoding: UTF-8

require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require './models/marathon.rb'
require './models/runner.rb'
require './models/count.rb'
require './models/audience.rb'

Marathon.create(name: '東京マラソン')
Marathon.create(name: '大阪マラソン')

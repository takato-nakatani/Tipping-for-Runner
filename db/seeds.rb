# encoding: UTF-8

require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require './models/marathon.rb'
require './models/runner.rb'
require './models/count.rb'
require './models/audience.rb'

# Marathon.create(name: '東京マラソン')
# Marathon.create(name: '大阪マラソン')

Runner.create({
    name: "ベンチャー",
    number: 1,
    marathon_id: 2,
    runner_line_id: "fiohviojv "
})

Audience.create(audience_line_id: "fhwejvnvj")

Count.create({
    number: 3,
    runner_line_id: "fiohviojv",
    audience_line_id: "fhwejvnvj"
})

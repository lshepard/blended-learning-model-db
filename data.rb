#
# Simple passthrough that supplies the Cloudant DB as a JSON file
#
require 'rubygems'
require 'bundler/setup'
require 'couchrest'
require 'sinatra'

get '/innosight.json' do
  @db = CouchRest.database("https://app4701148.heroku:oueLS2tF0oJjCCvIOk6xaHDi@app4701148.heroku.cloudant.com/example")
  data = @db.all_docs({include_docs:true})['rows'].map {|r| r['doc'].reject{|key,value| key.match(/^_/)}}

  # print response
  cache_control :public, :max_age => 600
  content_type 'application/json'
  'table_data = ' + JSON.pretty_generate(data)
end

#
# Simple passthrough that supplies the Cloudant DB as a JSON file
#
require 'rubygems'
require 'bundler/setup'
require 'couchrest'
require 'sinatra'
require 'json'
require 'mysql2'

get '/innosight.json' do
  @db = CouchRest.database("https://app4701148.heroku:oueLS2tF0oJjCCvIOk6xaHDi@app4701148.heroku.cloudant.com/example")
  data = @db.all_docs({include_docs:true})['rows'].map {|r| r['doc'].reject{|key,value| key.match(/^_/)}}

  # print response
  cache_control :public, :max_age => 600
  content_type 'application/json'
  'table_data = ' + JSON.pretty_generate(data)
end

# Arguments:
#   term       - search term
#   limit      - max number of items to return
get '/schools.json' do
  # todo: need to do this more "heroku-y"
  client = Mysql2::Client.new(:database => "test")

  term = params[:q].split
  limit = params[:limit].to_i;

  biz_name_terms = params[:q].split(/\s/).map { |x| 
    "biz_name LIKE '%#{client.escape(x)}%'" }.
    join(' AND ')
  
  results = client.query(
    "  (SELECT id, biz_name, dist_name, e_city, e_state, grade_low, grade_high, 'Y' as public" +
    "  FROM publicschools " +
    "  WHERE #{biz_name_terms}) " +
    "UNION " +
    "  (SELECT id, biz_name, school_religion as dist_name, e_city, e_state, grade_low, grade_high, 'N' as public" +
    "  FROM privateschools " +
    "  WHERE #{biz_name_terms}) " +
    "ORDER BY biz_name ASC " +
    "LIMIT #{limit}");
  
  data = []
  results.each do |row|
    data.push(row);
  end
  
  cache_control :public, :max_age => 5
  content_type 'application/json'
  "#{params[:callback]}(" + JSON.pretty_generate(data) + ')'
end
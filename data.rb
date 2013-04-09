#
# Simple passthrough that supplies the Cloudant DB as a JSON file
#
$: << File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'bundler/setup'
require 'couchrest'
require 'sinatra'
require 'sinatra/streaming'
require 'json'
require 'mysql2'
require 'innosight_csv_report'
require 'innosight_scraper'

get '/innosight.json' do
  data = fetch_couch_data
  
  # print response
  cache_control :public, :max_age => 600
  content_type 'application/json'
  'table_data = ' + JSON.pretty_generate(data)
end

get '/innosight.csv' do
  data = fetch_couch_data

  # print response
  attachment 'innosight.csv'
  content_type 'text/csv'

  InnosightCsvReport.new(data).to_csv
end

get '/scrape' do
  '<form action="./scrape" method="post"><input type="submit" value="Run scrape"></input></form>'
end

post '/scrape' do
  stream do |out|
    begin
      out.puts open("./html/scrapeheader.html").read
      InnosightScraper.new(out).upload
    rescue Exception => e
      out.puts "The scraper encountered an error:"
      out.puts e.message
      out.puts e.backtrace.join("\n")
    ensure
      out.puts open("./html/scrapefooter.html").read
    end
  end
  # InnosightScraper.new(STDOUT).upload
end

# Arguments:
#   term       - search term
#   limit      - max number of items to return
get '/schools.json' do
  # this sucks becasue it bypasses database.yml, doesn't use a local db, etc.
  # but oh well, want this to work so figure out how to do this later

  client = Mysql2::Client.new(:host => "us-cdbr-east.cleardb.com", :username => "553fbf15237f5f", :password => "7f144efa", :database => "heroku_c8050d70c833c4c")
 
  term = params[:q].split
  limit = params[:limit].to_i;

  biz_name_terms = params[:q].split(/\s/).map { |x|
    "biz_name LIKE '%#{client.escape(x)}%'" }.
    join(' AND ')

  district_name_terms = params[:q].split(/\s/).map { |x|
    "district_name LIKE '%#{client.escape(x)}%'" }.
    join(' AND ')

  cmo_name_terms = params[:q].split(/\s/).map { |x|
    "cmo_name LIKE '%#{client.escape(x)}%'" }.
    join(' AND ')

  school_name_terms = params[:q].split(/\s/).map { |x|
    "school_name LIKE '%#{client.escape(x)}%'" }.
    join(' AND ')
  
  results = client.query(
    "  (SELECT id, biz_name AS name, e_city, e_state, grade_low, grade_high, 'public' as type, 'Public School' as display_type" +
    "  FROM publicschools " +
    "  WHERE #{biz_name_terms}) " +
    "UNION " +
    "  (SELECT id, biz_name AS name, e_city, e_state, grade_low, grade_high, 'private' as type, school_type as display_type" +
    "  FROM privateschools " +
    "  WHERE #{biz_name_terms}) " +
    "UNION " +
    "  (SELECT id, district_name AS name, e_city, e_state, '' AS grade_low, '' AS grade_high, 'district' as type, dist_type as display_type" +
    "  FROM publicschooldistricts " +
    "  WHERE #{district_name_terms}) " +
    "UNION " +
    "  (SELECT DISTINCT cmo_name as id, cmo_name as name, group_concat(concat(city,' ',state)) as e_city, '' as e_state, min(grade_low) AS grade_low, max(grade_high) AS grade_high, 'cmo' as type, 'Charter Management Organization' as display_type" +
    "  FROM cmos " +
    "  WHERE (#{cmo_name_terms}) OR (#{school_name_terms}) " +
    "  GROUP BY cmo_name) " +
    "ORDER BY name ASC " +
    "LIMIT #{limit}");
  
  data = []
  results.each do |row|
    data.push(row);
  end
  
  cache_control :public, :max_age => 5
  content_type 'application/json'
  "#{params[:callback]}(" + JSON.pretty_generate(data) + ')'
end

def fetch_couch_data
  @db = CouchRest.database("https://app4701148.heroku:oueLS2tF0oJjCCvIOk6xaHDi@app4701148.heroku.cloudant.com/cci-scrape")
  # @db = CouchRest.database!("http://localhost:5984/bluscrapes")
  data = @db.all_docs({include_docs:true})['rows']
  # remove the non-data rows, such as design docs
  data.select! {|r| !r['id'].match(/^_/)}

  # remove the clouddb-specific keys, like _id and _rev
  data.map! {|r| r['doc'].reject{|key,value| key.match(/^_/)}}

  data
end

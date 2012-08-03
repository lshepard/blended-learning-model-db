#
# Most pages on this site - including the main index page - are static html, js, and css files.
# This code was ripped from https://devcenter.heroku.com/articles/static-sites-on-heroku

use Rack::Static, 
  :urls => ["/css", "/js", "/datatables", "/select2", "/intake", "/iframe"],
  :root => "html"

map '/' do
  run lambda { |env|
    [
      200, 
      {
        'Content-Type'  => 'text/html', 
        'Cache-Control' => 'public, max-age=10'
      },
      File.open('html/index.html', File::RDONLY)
    ]
  }
end

# The only dynamic pages are those that serve the JSON data directly from the Cloudant DB

require './data'
map '/data' do
  set :protection, :except => [:json_csrf]
  run Sinatra::Application
end

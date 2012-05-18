use Rack::Static, 
  :urls => [],
  :root => "public"

run lambda { |env|
  [
    200, 
    {
      'Content-Type'  => 'text/html', 
      'Cache-Control' => 'public, max-age=10'
    },
    File.open('public/index.html', File::RDONLY)
  ]
}


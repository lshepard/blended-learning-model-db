use Rack::Static, 
  :urls => ["/css", "/js", "/datatables"],
  :root => "html"

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


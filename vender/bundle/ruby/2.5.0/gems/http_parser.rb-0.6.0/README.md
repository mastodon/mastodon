# http_parser.rb

A simple callback-based HTTP request/response parser for writing http
servers, clients and proxies.

This gem is built on top of [joyent/http-parser](http://github.com/joyent/http-parser) and its java port [http-parser/http-parser.java](http://github.com/http-parser/http-parser.java).

## Supported Platforms

This gem aims to work on all major Ruby platforms, including:

- MRI 1.8 and 1.9
- Rubinius
- JRuby
- win32

## Usage

```ruby
require "http/parser"

parser = Http::Parser.new

parser.on_headers_complete = proc do
  p parser.http_version

  p parser.http_method # for requests
  p parser.request_url

  p parser.status_code # for responses

  p parser.headers
end

parser.on_body = proc do |chunk|
  # One chunk of the body
  p chunk
end

parser.on_message_complete = proc do |env|
  # Headers and body is all parsed
  puts "Done!"
end
```

# Feed raw data from the socket to the parser
`parser << raw_data`

## Advanced Usage

### Accept callbacks on an object

```ruby
module MyHttpConnection
  def connection_completed
    @parser = Http::Parser.new(self)
  end

  def receive_data(data)
    @parser << data
  end

  def on_message_begin
    @headers = nil
    @body = ''
  end

  def on_headers_complete(headers)
    @headers = headers
  end

  def on_body(chunk)
    @body << chunk
  end

  def on_message_complete
    p [@headers, @body]
  end
end
```

### Stop parsing after headers

```ruby
parser = Http::Parser.new
parser.on_headers_complete = proc{ :stop }

offset = parser << request_data
body = request_data[offset..-1]
```

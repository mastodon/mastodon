# Faraday

[![Gem Version](https://badge.fury.io/rb/faraday.svg)](https://rubygems.org/gems/faraday)
[![Build Status](https://travis-ci.org/lostisland/faraday.svg)](https://travis-ci.org/lostisland/faraday)
[![Coverage Status](https://coveralls.io/repos/github/lostisland/faraday/badge.svg?branch=master)](https://coveralls.io/github/lostisland/faraday?branch=master)
[![Code Climate](https://codeclimate.com/github/lostisland/faraday/badges/gpa.svg)](https://codeclimate.com/github/lostisland/faraday)
[![Gitter](https://badges.gitter.im/lostisland/faraday.svg)](https://gitter.im/lostisland/faraday?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)


Faraday is an HTTP client lib that provides a common interface over many
adapters (such as Net::HTTP) and embraces the concept of Rack middleware when
processing the request/response cycle.

Faraday supports these adapters out of the box:

* [Net::HTTP][net_http] _(default)_
* [Net::HTTP::Persistent][persistent]
* [Excon][]
* [Patron][]
* [EventMachine][]
* [HTTPClient][]

Adapters are slowly being moved into their own gems, or bundled with HTTP clients:

* [Typhoeus][]

It also includes a Rack adapter for hitting loaded Rack applications through
Rack::Test, and a Test adapter for stubbing requests by hand.

## API documentation

Available at [rubydoc.info](http://www.rubydoc.info/gems/faraday).

## Usage

### Basic Use

```ruby
response = Faraday.get 'http://sushi.com/nigiri/sake.json'
```
A simple `get` request can be performed by using the syntax described above. This works if you don't need to set up anything; you can roll with just the default middleware
stack and default adapter (see [Faraday::RackBuilder#initialize](https://github.com/lostisland/faraday/blob/master/lib/faraday/rack_builder.rb)).

A more flexible way to use Faraday is to start with a Connection object. If you want to keep the same defaults, you can use this syntax:

```ruby
conn = Faraday.new(:url => 'http://www.example.com')
response = conn.get '/users'                 # GET http://www.example.com/users'
```

Connections can also take an options hash as a parameter or be configured by using a block. Checkout the section called [Advanced middleware usage](#advanced-middleware-usage) for more details about how to use this block for configurations.
Since the default middleware stack uses url\_encoded middleware and default adapter, use them on building your own middleware stack.

```ruby
conn = Faraday.new(:url => 'http://sushi.com') do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

# Filter sensitive information from logs with a regex matcher

conn = Faraday.new(:url => 'http://sushi.com/api_key=s3cr3t') do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger do | logger |
    logger.filter(/(api_key=)(\w+)/,'\1[REMOVED]')
  end
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end
```

Once you have the connection object, use it to make HTTP requests. You can pass paramters to it in a few different ways:

```ruby
## GET ##

response = conn.get '/nigiri/sake.json'     # GET http://sushi.com/nigiri/sake.json
response.body

conn.get '/nigiri', { :name => 'Maguro' }   # GET http://sushi.com/nigiri?name=Maguro

conn.get do |req|                           # GET http://sushi.com/search?page=2&limit=100  
  req.url '/search', :page => 2
  req.params['limit'] = 100
end

## POST ##

conn.post '/nigiri', { :name => 'Maguro' }  # POST "name=maguro" to http://sushi.com/nigiri
```

Some configuration options can be adjusted per request:

```ruby
# post payload as JSON instead of "www-form-urlencoded" encoding:
conn.post do |req|
  req.url '/nigiri'
  req.headers['Content-Type'] = 'application/json'
  req.body = '{ "name": "Unagi" }'
end

## Per-request options ##

conn.get do |req|
  req.url '/search'
  req.options.timeout = 5           # open/read timeout in seconds
  req.options.open_timeout = 2      # connection open timeout in seconds
end
```

And you can inject arbitrary data into the request using the `context` option:

```ruby
# Anything you inject using context option will be available in the env on all middlewares

conn.get do |req|
  req.url '/search'
  req.options.context = {
      foo: 'foo',
      bar: 'bar'
  }          
end
```

### Changing how parameters are serialized

Sometimes you need to send the same URL parameter multiple times with different
values. This requires manually setting the parameter encoder and can be done on
either per-connection or per-request basis.

```ruby
# per-connection setting
conn = Faraday.new :request => { :params_encoder => Faraday::FlatParamsEncoder }

conn.get do |req|
  # per-request setting:
  # req.options.params_encoder = my_encoder
  req.params['roll'] = ['california', 'philadelphia']
end
# GET 'http://sushi.com?roll=california&roll=philadelphia'
```

The value of Faraday `params_encoder` can be any object that responds to:

* `encode(hash) #=> String`
* `decode(string) #=> Hash`

The encoder will affect both how query strings are processed and how POST bodies
get serialized. The default encoder is Faraday::NestedParamsEncoder.

## Authentication

Basic and Token authentication are handled by Faraday::Request::BasicAuthentication and Faraday::Request::TokenAuthentication respectively. These can be added as middleware manually or through the helper methods.

```ruby
Faraday.new(...) do |conn|
  conn.basic_auth('username', 'password')
end

Faraday.new(...) do |conn|
  conn.token_auth('authentication-token')
end
```

## Proxy

Faraday will try to automatically infer the proxy settings from your system using `URI#find_proxy`.
This will retrieve them from environment variables such as http_proxy, ftp_proxy, no_proxy, etc.
If for any reason you want to disable this behaviour, you can do so by setting the global varibale `ignore_env_proxy`:

```ruby
Faraday.ignore_env_proxy = true
```

You can also specify a custom proxy when initializing the connection

```ruby
Faraday.new('http://www.example.com', :proxy => 'http://proxy.com')
```

## Advanced middleware usage

The order in which middleware is stacked is important. Like with Rack, the
first middleware on the list wraps all others, while the last middleware is the
innermost one, so that must be the adapter.

```ruby
Faraday.new(...) do |conn|
  # POST/PUT params encoders:
  conn.request :multipart
  conn.request :url_encoded

  # Last middleware must be the adapter:
  conn.adapter :net_http
end
```

This request middleware setup affects POST/PUT requests in the following way:

1. `Request::Multipart` checks for files in the payload, otherwise leaves
  everything untouched;
2. `Request::UrlEncoded` encodes as "application/x-www-form-urlencoded" if not
  already encoded or of another type

Swapping middleware means giving the other priority. Specifying the
"Content-Type" for the request is explicitly stating which middleware should
process it.

Examples:

```ruby
# uploading a file:
payload[:profile_pic] = Faraday::UploadIO.new('/path/to/avatar.jpg', 'image/jpeg')

# "Multipart" middleware detects files and encodes with "multipart/form-data":
conn.put '/profile', payload
```

## Writing middleware

Middleware are classes that implement a `call` instance method. They hook into
the request/response cycle.

```ruby
def call(request_env)
  # do something with the request
  # request_env[:request_headers].merge!(...)

  @app.call(request_env).on_complete do |response_env|
    # do something with the response
    # response_env[:response_headers].merge!(...)
  end
end
```

It's important to do all processing of the response only in the `on_complete`
block. This enables middleware to work in parallel mode where requests are
asynchronous.

The `env` is a hash with symbol keys that contains info about the request and,
later, response. Some keys are:

```
# request phase
:method - :get, :post, ...
:url    - URI for the current request; also contains GET parameters
:body   - POST parameters for :post/:put requests
:request_headers

# response phase
:status - HTTP response status code, such as 200
:body   - the response body
:response_headers
```

## Ad-hoc adapters customization

Faraday is intended to be a generic interface between your code and the adapter. However, sometimes you need to access a feature specific to one of the adapters that is not covered in Faraday's interface.

When that happens, you can pass a block when specifying the adapter to customize it. The block parameter will change based on the adapter you're using. See below for some examples.

### NetHttp
```ruby
conn = Faraday.new(...) do |f|
  f.adapter :net_http do |http| # yields Net::HTTP
    http.idle_timeout = 100
    http.verify_callback = lambda do | preverify_ok, cert_store |
      # do something here...
    end
  end
end
```

### NetHttpPersistent
```ruby
conn = Faraday.new(...) do |f|
  f.adapter :net_http_persistent do |http| # yields Net::HTTP::Persistent
    http.idle_timeout = 100
    http.retry_change_requests = true
  end
end
```

### Patron
```ruby
conn = Faraday.new(...) do |f|
  f.adapter :patron do |session| # yields Patron::Session
    session.max_redirects = 10
  end
end
```

### HTTPClient
```ruby
conn = Faraday.new(...) do |f|
  f.adapter :httpclient do |client| # yields HTTPClient
    client.keep_alive_timeout = 20
    client.ssl_config.timeout = 25
  end
end
```

## Using Faraday for testing

```ruby
# It's possible to define stubbed request outside a test adapter block.
stubs = Faraday::Adapter::Test::Stubs.new do |stub|
  stub.get('/tamago') { |env| [200, {}, 'egg'] }
end

# You can pass stubbed request to the test adapter or define them in a block
# or a combination of the two.
test = Faraday.new do |builder|
  builder.adapter :test, stubs do |stub|
    stub.get('/ebi') { |env| [ 200, {}, 'shrimp' ]}
  end
end

# It's also possible to stub additional requests after the connection has
# been initialized. This is useful for testing.
stubs.get('/uni') { |env| [ 200, {}, 'urchin' ]}

resp = test.get '/tamago'
resp.body # => 'egg'
resp = test.get '/ebi'
resp.body # => 'shrimp'
resp = test.get '/uni'
resp.body # => 'urchin'
resp = test.get '/else' #=> raises "no such stub" error

# If you like, you can treat your stubs as mocks by verifying that all of
# the stubbed calls were made. NOTE that this feature is still fairly
# experimental: It will not verify the order or count of any stub, only that
# it was called once during the course of the test.
stubs.verify_stubbed_calls
```

## Supported Ruby versions

This library aims to support and is [tested against][travis] the following Ruby
implementations:

* Ruby 1.9.3+
* [JRuby][] 1.7+
* [Rubinius][] 2+

If something doesn't work on one of these Ruby versions, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby
implementations, however support will only be provided for the versions listed
above.

If you would like this library to support another Ruby version, you may
volunteer to be a maintainer. Being a maintainer entails making sure all tests
run and pass on that implementation. When something breaks on your
implementation, you will be responsible for providing patches in a timely
fashion. If critical issues for a particular implementation exist at the time
of a major release, support for that Ruby version may be dropped.

## Contribute

Do you want to contribute to Faraday?
Open the issues page and check for the `any volunteer?` label!
But before you start coding, please read our [Contributing Guide](https://github.com/lostisland/faraday/blob/master/.github/CONTRIBUTING.md)

## Copyright

Copyright (c) 2009-2017 [Rick Olson](mailto:technoweenie@gmail.com), Zack Hobson.
See [LICENSE][] for details.

[net_http]:     http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/Net/HTTP.html
[persistent]:   https://github.com/drbrain/net-http-persistent
[travis]:       https://travis-ci.org/lostisland/faraday
[excon]:        https://github.com/excon/excon#readme
[patron]:       http://toland.github.io/patron/
[eventmachine]: https://github.com/igrigorik/em-http-request#readme
[httpclient]:   https://github.com/nahi/httpclient
[typhoeus]:     https://github.com/typhoeus/typhoeus/blob/master/lib/typhoeus/adapters/faraday.rb
[jruby]:        http://jruby.org/
[rubinius]:     http://rubini.us/
[license]:      LICENSE.md

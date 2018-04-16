# excon

Usable, fast, simple Ruby HTTP 1.1

Excon was designed to be simple, fast and performant. It works great as a general HTTP(s) client and is particularly well suited to usage in API clients.

[![Build Status](https://travis-ci.org/excon/excon.svg?branch=master)](https://travis-ci.org/excon/excon)
[![Dependency Status](https://gemnasium.com/excon/excon.svg)](https://gemnasium.com/excon/excon)
[![Gem Version](https://badge.fury.io/rb/excon.svg)](https://badge.fury.io/rb/excon)
[![Gittip](https://img.shields.io/gittip/geemus.svg)](https://www.gittip.com/geemus/)

* [Getting Started](#getting-started)
* [Options](#options)
* [Chunked Requests](#chunked-requests)
* [Pipelining Requests](#pipelining-requests)
* [Streaming Responses](#streaming-responses)
* [Proxy Support](#proxy-support)
* [Reusable ports](#reusable-ports)
* [Unix Socket Support](#unix-socket-support)
* [Stubs](#stubs)
* [Instrumentation](#instrumentation)
* [HTTPS client certificate](#https-client-certificate)
* [HTTPS/SSL Issues](#httpsssl-issues)
* [Getting Help](#getting-help)
* [Contributing](#contributing)
* [Plugins and Middlewares](#plugins-and-middlewares)
* [License](#license)

## Getting Started

Install the gem.

```
$ sudo gem install excon
```

Require with rubygems.

```ruby
require 'rubygems'
require 'excon'
```

The easiest way to get started is by using one-off requests. Supported one-off request methods are `connect`, `delete`, `get`, `head`, `options`, `post`, `put`, and `trace`. Requests return a response object which has `body`, `headers`, `remote_ip` and `status` attributes.

```ruby
response = Excon.get('http://geemus.com')
response.body       # => "..."
response.headers    # => {...}
response.remote_ip  # => "..."
response.status     # => 200
```

For API clients or other ongoing usage, reuse a connection across multiple requests to share options and improve performance.

```ruby
connection = Excon.new('http://geemus.com')
get_response = connection.get
post_response = connection.post(:path => '/foo')
delete_response = connection.delete(:path => '/bar')
```

By default, each connection is non-persistent. This means that each request made against a connection behaves like a
one-off request. Each request will establish a socket connection to the server, then close the socket once the request
is complete.

To use a persistent connection, use the `:persistent` option:

```ruby
connection = Excon.new('http://geemus.com', :persistent => true)
```

The initial request will establish a socket connection to the server and leave the socket open. Subsequent requests
will reuse that socket. You may call `Connection#reset` at any time to close the underlying socket, and the next request
will establish a new socket connection.

You may also control persistence on a per-request basis by setting the `:persistent` option for each request.

```ruby
connection = Excon.new('http://geemus.com') # non-persistent by default
connection.get # socket established, then closed
connection.get(:persistent => true) # socket established, left open
connection.get(:persistent => true) # socket reused
connection.get # socket reused, then closed

connection = Excon.new('http://geemus.com', :persistent => true)
connection.get # socket established, left open
connection.get(:persistent => false) # socket reused, then closed
connection.get(:persistent => false) # socket established, then closed
connection.get # socket established, left open
connection.get # socket reused
```

Note that sending a request with `:persistent => false` to close the socket will also send `Connection: close` to inform
the server the connection is no longer needed. `Connection#reset` will simply close our end of the socket.


## Options

Both one-off and persistent connections support many other options. The final options for a request are built up by starting with `Excon.defaults`, then merging in options from the connection and finally merging in any request options. In this way you have plenty of options on where and how to set options and can easily setup connections or defaults to match common options for a particular endpoint.

Here are a few common examples:

```ruby
# Output debug info, similar to ENV['EXCON_DEBUG']
connection = Excon.new('http://geemus.com/', :debug_request => true, :debug_response => true)

# Custom headers
Excon.get('http://geemus.com', :headers => {'Authorization' => 'Basic 0123456789ABCDEF'})
connection.get(:headers => {'Authorization' => 'Basic 0123456789ABCDEF'})

# Changing query strings
connection = Excon.new('http://geemus.com/')
connection.get(:query => {:foo => 'bar'})

# POST body encoded with application/x-www-form-urlencoded
Excon.post('http://geemus.com',
  :body => 'language=ruby&class=fog',
  :headers => { "Content-Type" => "application/x-www-form-urlencoded" })

# same again, but using URI to build the body of parameters
Excon.post('http://geemus.com',
  :body => URI.encode_www_form(:language => 'ruby', :class => 'fog'),
  :headers => { "Content-Type" => "application/x-www-form-urlencoded" })

# request takes a method option, accepting either a symbol or string
connection.request(:method => :get)
connection.request(:method => 'GET')

# expect one or more status codes, or raise an error
connection.request(:expects => [200, 201], :method => :get)

# this request can be repeated safely, so retry on errors up to 3 times
connection.request(:idempotent => true)

# this request can be repeated safely, retry up to 6 times
connection.request(:idempotent => true, :retry_limit => 6)

# this request can be repeated safely, retry up to 6 times and sleep 5 seconds
# in between each retry
connection.request(:idempotent => true, :retry_limit => 6, :retry_interval => 5)

# set longer read_timeout (default is 60 seconds)
connection.request(:read_timeout => 360)

# set longer write_timeout (default is 60 seconds)
connection.request(:write_timeout => 360)

# Enable the socket option TCP_NODELAY on the underlying socket.
#
# This can improve response time when sending frequent short
# requests in time-sensitive scenarios.
#
connection = Excon.new('http://geemus.com/', :tcp_nodelay => true)

# set longer connect_timeout (default is 60 seconds)
connection = Excon.new('http://geemus.com/', :connect_timeout => 360)

# opt-out of nonblocking operations for performance and/or as a workaround
connection = Excon.new('http://geemus.com/', :nonblock => false)

# use basic authentication by supplying credentials in the URL or as parameters
connection = Excon.new('http://username:password@secure.geemus.com')
connection = Excon.new('http://secure.geemus.com',
  :user => 'username', :password => 'password')

# use custom uri parser
require 'addressable/uri'
connection = Excon.new('http://geemus.com/', uri_parser: Addressable::URI)
```

Compared to web browsers and other http client libraries, e.g. curl, Excon is a bit more low-level and doesn't assume much by default. If you are seeing different results compared to other clients, the following options might help:

```ruby
# opt-in to omitting port from http:80 and https:443
connection = Excon.new('http://geemus.com/', :omit_default_port => true)

# accept gzip encoding
connection = Excon.new('http://geemus.com/', :headers => { "Accept-Encoding" => "gzip" })

# turn off peer verification (less secure)
Excon.defaults[:ssl_verify_peer] = false
connection = Excon.new('https://...')
```

## Chunked Requests

You can make `Transfer-Encoding: chunked` requests by passing a block that will deliver chunks, delivering an empty chunk to signal completion.

```ruby
file = File.open('data')

chunker = lambda do
  # Excon.defaults[:chunk_size] defaults to 1048576, ie 1MB
  # to_s will convert the nil received after everything is read to the final empty chunk
  file.read(Excon.defaults[:chunk_size]).to_s
end

Excon.post('http://geemus.com', :request_block => chunker)

file.close
```

Iterating in this way allows you to have more granular control over writes and to write things where you can not calculate the overall length up front.

## Pipelining Requests

You can make use of HTTP pipelining to improve performance. Instead of the normal request/response cycle, pipelining sends a series of requests and then receives a series of responses. You can take advantage of this using the `requests` method, which takes an array of params where each is a hash like request would receive and returns an array of responses.

```ruby
connection = Excon.new('http://geemus.com/')
connection.requests([{:method => :get}, {:method => :get}])
```

By default, each call to `requests` will use a separate persistent socket connection. To make multiple `requests` calls
using a single persistent connection, set `:persistent => true` when establishing the connection.

For large numbers of simultaneous requests please consider using the `batch_requests` method. This will automatically slice up the requests into batches based on the file descriptor limit of your operating system. The results are the same as the `requests` method, but using this method can help prevent timeout errors.

```ruby
large_array_of_requests = [{:method => :get, :path => 'some_path'}, { ... }] # Hundreds of items
connection.batch_requests(large_array_of_requests)
```

## Streaming Responses

You can stream responses by passing a block that will receive each chunk.

```ruby
streamer = lambda do |chunk, remaining_bytes, total_bytes|
  puts chunk
  puts "Remaining: #{remaining_bytes.to_f / total_bytes}%"
end

Excon.get('http://geemus.com', :response_block => streamer)
```

Iterating over each chunk will allow you to do work on the response incrementally without buffering the entire response first. For very large responses this can lead to significant memory savings.

## Proxy Support

You can specify a proxy URL that Excon will use with both HTTP and HTTPS connections:

```ruby
connection = Excon.new('http://geemus.com', :proxy => 'http://my.proxy:3128')
connection.request(:method => 'GET')

Excon.get('http://geemus.com', :proxy => 'http://my.proxy:3128')
```

The proxy URL must be fully specified, including scheme (e.g. "http://") and port.

Proxy support must be set when establishing a connection object and cannot be overridden in individual requests.

NOTE: Excon will use the environment variables `http_proxy` and `https_proxy` if they are present. If these variables are set they will take precedence over a :proxy option specified in code. If "https_proxy" is not set, the value of "http_proxy" will be used for both HTTP and HTTPS connections.

## Reusable ports

For advanced cases where you'd like to reuse the local port assigned to the excon socket in another socket, use the `:reuseaddr` option.

```ruby
connection = Excon.new('http://geemus.com', :reuseaddr => true)
connection.get

s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
if defined?(Socket::SO_REUSEPORT)
  s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true)
end

s.bind(Socket.pack_sockaddr_in(connection.local_port, connection.local_address))
s.connect(Socket.pack_sockaddr_in(80, '1.2.3.4'))
puts s.read
s.close
```

## Unix Socket Support

The Unix socket will work for one-off requests and multiuse connections.  A Unix socket path must be provided separate from the resource path.

```ruby
connection = Excon.new('unix:///', :socket => '/tmp/unicorn.sock')
connection.request(:method => :get, :path => '/ping')

Excon.get('unix:///ping', :socket => '/tmp/unicorn.sock')
```

NOTE: Proxies will be ignored when using a Unix socket, since a Unix socket has to be local.

## Stubs

You can stub out requests for testing purposes by enabling mock mode on a connection.

```ruby
connection = Excon.new('http://example.com', :mock => true)
```

Or by enabling mock mode for a request.

```ruby
connection.request(:method => :get, :path => 'example', :mock => true)
```

Add stubs by providing the request attributes to match and response attributes to return. Response params can be specified as either a hash or block which will yield with the request params.

```ruby
Excon.stub({}, {:body => 'body', :status => 200})
Excon.stub({}, lambda {|request_params| {:body => request_params[:body], :status => 200}})
```

Omitted attributes are assumed to match, so this stub will match *any* request and return an Excon::Response with a body of 'body' and status of 200.  You can add whatever stubs you might like this way and they will be checked against in the order they were added, if none of them match then excon will raise an `Excon::Errors::StubNotFound` error to let you know.

If you want to allow unstubbed requests without raising `StubNotFound`, set the `allow_unstubbed_requests` option either globally or per request.

```ruby
connection = Excon.new('http://example.com', :mock => true, :allow_unstubbed_requests => true)
```

To remove a previously defined stub, or all stubs:

```ruby
Excon.unstub({})  # remove first/oldest stub matching {}
Excon.stubs.clear # remove all stubs
```

For example, if using RSpec for your test suite you can clear stubs after running each example:

```ruby
config.after(:each) do
  Excon.stubs.clear
end
```

You can also modify `Excon.defaults` to set a stub for all requests, so for a test suite you might do this:

```ruby
# Mock by default and stub any request as success
config.before(:all) do
  Excon.defaults[:mock] = true
  Excon.stub({}, {:body => 'Fallback', :status => 200})
  # Add your own stubs here or in specific tests...
end
```

By default stubs are shared globally, to make stubs unique to each thread, use `Excon.defaults[:stubs] = :local`.

## Instrumentation

Excon calls can be timed using the [ActiveSupport::Notifications](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html) API.

```ruby
connection = Excon.new(
  'http://geemus.com',
  :instrumentor => ActiveSupport::Notifications
)
```

Excon will then instrument each request, retry, and error.  The corresponding events are named `excon.request`, `excon.retry`, and `excon.error` respectively.

```ruby
ActiveSupport::Notifications.subscribe(/excon/) do |*args|
  puts "Excon did stuff!"
end
```

If you prefer to label each event with a namespace other than "excon", you may specify
an alternate name in the constructor:

```ruby
connection = Excon.new(
  'http://geemus.com',
  :instrumentor => ActiveSupport::Notifications,
  :instrumentor_name => 'my_app'
)
```

Note: Excon's ActiveSupport::Notifications implementation has the following event format: `<namespace>.<event>` which is the opposite of the Rails' implementation.

ActiveSupport provides a [subscriber](http://api.rubyonrails.org/classes/ActiveSupport/Subscriber.html) interface which lets you attach a subscriber to a namespace. Due to the incompability above, you won't be able to attach a subscriber to the "excon" namespace out of the box.

If you want this functionality, you can use a simple adapter such as this one:

```ruby
class ExconToRailsInstrumentor
  def self.instrument(name, datum, &block)
    namespace, *event = name.split(".")
    rails_name = [event, namespace].flatten.join(".")
    ActiveSupport::Notifications.instrument(rails_name, datum, &block)
  end
end
```

If you don't want to add ActiveSupport to your application, simply define a class which implements the same `#instrument` method like so:

```ruby
class SimpleInstrumentor
  class << self
    attr_accessor :events

    def instrument(name, params = {}, &block)
      puts "#{name} just happened."
      yield if block_given?
    end
  end
end
```

The #instrument method will be called for each HTTP request, response, retry, and error.

For debugging purposes you can also use `Excon::StandardInstrumentor` to output all events to stderr. This can also be specified by setting the `EXCON_DEBUG` ENV var.

See [the documentation for ActiveSupport::Notifications](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html) for more detail on using the subscription interface.  See excon's [instrumentation_test.rb](https://github.com/excon/excon/blob/master/tests/middlewares/instrumentation_tests.rb) for more examples of instrumenting excon.

## HTTPS client certificate

You can supply a client side certificate if the server requires it for authentication:

```ruby
connection = Excon.new('https://example.com',
                       client_cert: 'mycert.pem',
                       client_key: 'mycert.key',
                       client_key_pass: 'my pass phrase')
```

`client_key_pass` is optional.

If you already have loaded the certificate and key into memory, then pass it through like:

```ruby
client_cert_data = File.load 'mycert.pem'
client_key_data = File.load 'mycert.key'

connection = Excon.new('https://example.com',
                       client_cert_data: client_cert_data,
                       client_key_data: client_key_data)
```

This can be useful if your program has already loaded the assets through
another mechanism (E.g. a remote API call to a secure K:V system like Vault).

## HTTPS/SSL Issues

By default excon will try to verify peer certificates when using HTTPS. Unfortunately on some operating systems the defaults will not work. This will likely manifest itself as something like `Excon::Errors::CertificateError: SSL_connect returned=1 ...`

If you have the misfortune of running into this problem you have a couple options. If you have certificates but they aren't being auto-discovered, you can specify the path to your certificates:

```ruby
Excon.defaults[:ssl_ca_path] = '/path/to/certs'
```

Failing that, you can turn off peer verification (less secure):

```ruby
Excon.defaults[:ssl_verify_peer] = false
```

Either of these should allow you to work around the socket error and continue with your work.

## Getting Help

* Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/excon).
* Report bugs and discuss potential features in [Github issues](https://github.com/excon/excon/issues).

## Contributing

Please refer to [CONTRIBUTING.md](https://github.com/excon/excon/blob/master/CONTRIBUTING.md).

# Plugins and Middlewares

Using Excon's [Middleware system][middleware], you can easily extend Excon's
functionality with your own. The following plugins extend Excon in their own
way:

* [excon-addressable](https://github.com/JeanMertz/excon-addressable)

  Set [addressable](https://github.com/sporkmonger/addressable) as the default
  URI parser, and add support for [URI templating][templating].

* [excon-hypermedia](https://github.com/JeanMertz/excon-hypermedia)

  Teaches Excon to talk with [HyperMedia APIs][hypermedia]. Allowing you to use
  all of Excon's functionality, while traversing APIs in an easy and
  self-discovering way.

## License

Please refer to [LICENSE.md](https://github.com/excon/excon/blob/master/LICENSE.md).

[middleware]: lib/excon/middlewares/base.rb
[hypermedia]: https://en.wikipedia.org/wiki/HATEOAS
[templating]: https://www.rfc-editor.org/rfc/rfc6570.txt

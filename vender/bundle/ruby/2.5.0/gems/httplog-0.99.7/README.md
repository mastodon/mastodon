## httplog

[![Gem Version](https://badge.fury.io/rb/httplog.png)](http://badge.fury.io/rb/httplog) [![Build Status](https://travis-ci.org/trusche/httplog.svg?branch=master)](https://travis-ci.org/trusche/httplog) [![Code Climate](https://codeclimate.com/github/trusche/httplog.png)](https://codeclimate.com/github/trusche/httplog)

**+++ This is the README for version 0.99.0 and higher. If you're on previous versions, please refer to [this README version](https://github.com/trusche/httplog/tree/v0.3.3), since the configuration syntax has changed.+++**

Log outgoing HTTP requests made from your application. Helps with debugging pesky API error responses, or just generally understanding what's going on under the hood.

**+++Requires ruby 2.2 or higher. If you're stuck with an older version of ruby for some reason, you're stuck with httplog v0.3.3.+++**

This gem works with the following ruby modules and libraries:

* [Net::HTTP](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/index.html)
* [Ethon](https://github.com/typhoeus/ethon)
* [Excon](https://github.com/geemus/excon)
* [OpenURI](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/open-uri/rdoc/index.html)
* [Patron](https://github.com/toland/patron)
* [HTTPClient](https://github.com/nahi/httpclient)
* [HTTParty](https://github.com/jnunemaker/httparty)
* [HTTP](https://github.com/httprb/http)

These libraries are at least partially supported, where they use one of the above as adapters, but not explicitly tested - YMMV:

* [Faraday](https://github.com/technoweenie/faraday)
* [Typhoeus](https://github.com/typhoeus/typhoeus)

In theory, it should also work with any library built on top of these. But the difference between theory and practice is bigger in practice than in theory.

This is very much a development and debugging tool; it is **not recommended** to
use this in a production environment as it is moneky-patching the respective HTTP implementations.
You have been warned - use at your own risk.

### Installation

    gem install httplog

### Usage

    require 'httplog' # require this *after* your HTTP gem of choice

By default, this will log all outgoing HTTP requests and their responses to $stdout on DEBUG level.

### Notes on content types

* Binary data from response bodies (as indicated by the `Content-Type` header)is not logged.
* Text data (`text/*` and most `application/*` types) is encoded as UTF-8, with invalid characters replaced. If you need to inspect raw non-UTF data exactly as sent over the wire, this tool is probably not for you.

### Configuration

You can override the following default options:

```ruby
HttpLog.configure do |config|

  # Enable or disable all logging
  config.enabled = true

  # You can assign a different logger
  config.logger = Logger.new($stdout)

  # I really wouldn't change this...
  config.severity = Logger::Severity::DEBUG

  # Tweak which parts of the HTTP cycle to log...
  config.log_connect   = true
  config.log_request   = true
  config.log_headers   = false
  config.log_data      = true
  config.log_status    = true
  config.log_response  = true
  config.log_benchmark = true

  # ...or log all request as a single line by setting this to `true`
  config.compact_log = false

  # Prettify the output - see below
  config.color = false

  # Limit logging based on URL patterns
  config.url_whitelist_pattern = /.*/
  config.url_blacklist_pattern = nil
end
```

If you want to use this in a Rails app, I'd suggest configuring this specifically for each environment. A global initializer is not a good idea since `HttpLog` will be undefined in production. Because you're **not using this in production**, right? :)

```ruby
# config/environments/development.rb

HttpLog.configure do |config|
  config.logger = Rails.logger
end
```

You can colorize the output to make it stand out in your logfile:

```ruby
HttpLog.configure do |config|
  config.color = {color: :black, background: :light_red}
end
```

For more color options [please refer to the colorize documentation](https://github.com/fazibear/colorize/blob/master/README.md)

### Compact logging

If the log is too noisy for you, but you don't want to completely disable it either, set the `compact_log` option to `true`. This will log each request in a single line with method, request URI, response status and time, but no data or headers. No need to disable any other options individually.

### Example

With the default configuration, the log output might look like this:

    D, [2012-11-21T15:09:03.532970 #6857] DEBUG -- : [httplog] Connecting: localhost:80
    D, [2012-11-21T15:09:03.533877 #6857] DEBUG -- : [httplog] Sending: GET http://localhost:9292/index.html
    D, [2012-11-21T15:09:03.534499 #6857] DEBUG -- : [httplog] Status: 200
    D, [2012-11-21T15:09:03.534544 #6857] DEBUG -- : [httplog] Benchmark: 0.00057 seconds
    D, [2012-11-21T15:09:03.534578 #6857] DEBUG -- : [httplog] Response:
    <html>
      <head>
        <title>Test Page</title>
      </head>
      <body>
        <h1>This is the test page.</h1>
      </body>
    </html>

With `compact_log` enabled, the same request might look like this:

    [httplog] GET http://localhost:9292/index.html completed with status code 200 in 0.00057 seconds

### Known Issues

* Requests types other than GET and POST have not been explicitly tested.
  They may or may not be logged, depending on the implementation details of the underlying library.
  If they are not for a particular library, please feel free to open an issue with the details.

* When using OpenURI, the reading of the HTTP response body is deferred,
  so it is not available for logging. This will be noted in the logging statement:

        D, [2012-11-21T15:09:03.547005 #6857] DEBUG -- : [httplog] Connecting: localhost:80
        D, [2012-11-21T15:09:03.547938 #6857] DEBUG -- : [httplog] Sending: GET http://localhost:9292/index.html
        D, [2012-11-21T15:09:03.548615 #6857] DEBUG -- : [httplog] Status: 200
        D, [2012-11-21T15:09:03.548662 #6857] DEBUG -- : [httplog] Benchmark: 0.000617 seconds
        D, [2012-11-21T15:09:03.548695 #6857] DEBUG -- : [httplog] Response: (not available yet)

*  When using HTTPClient, the TCP connection establishment will be logged
   *after* the HTTP request and headers, due to the way HTTPClient is organized.

        D, [2012-11-22T18:39:46.031698 #12800] DEBUG -- : [httplog] Sending: GET http://localhost:9292/index.html
        D, [2012-11-22T18:39:46.031756 #12800] DEBUG -- : [httplog] Header: accept: */*
        D, [2012-11-22T18:39:46.031788 #12800] DEBUG -- : [httplog] Header: foo: bar
        D, [2012-11-22T18:39:46.031942 #12800] DEBUG -- : [httplog] Connecting: localhost:9292
        D, [2012-11-22T18:39:46.033409 #12800] DEBUG -- : [httplog] Status: 200
        D, [2012-11-22T18:39:46.033483 #12800] DEBUG -- : [httplog] Benchmark: 0.001562 seconds

* Also when using HTTPClient, make sure you include `httplog` **after** `httpclient` in your `Gemfile`.

* When using Ethon or Patron, and any library based on them (such as Typhoeus),
  the TCP connection is not logged (since it's established by libcurl).

* Benchmarking only covers the time between starting the HTTP request and receiving the response. It does *not* cover the time it takes to establish the TCP connection.

### Running the specs

Make sure you have the necessary dependencies installed by running `bundle install`.
Then simply run `bundle exec rspec spec`.
This will launch a simple rack server on port 9292 and run all tests locally against that server.

### Contributing

If you have any issues with httplog,
or feature requests,
please [add an issue](https://github.com/trusche/httplog/issues) on GitHub
or fork the project and send a pull request.
Please include passing specs with all pull requests.

### Contributors

Thanks to these fine folks for contributing pull requests:

* [Doug Johnston](https://github.com/dougjohnston)
* [Eric Cohen](https://github.com/eirc)
* [Nikos Dimitrakopoulos](https://github.com/nikosd)
* [Marcos Hack](https://github.com/marcoshack)
* [Andrew Hammond](https://github.com/andrhamm)
* [Chris Keele](https://github.com/christhekeele)
* [Ryan Souza](https://github.com/ryansouza)
* [Ilya Bondarenko](https://github.com/sedx)
* [Kostas Zacharakis](https://github.com/kzacharakis)

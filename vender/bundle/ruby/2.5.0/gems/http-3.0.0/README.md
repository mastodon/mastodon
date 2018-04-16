# ![http.rb](https://raw.github.com/httprb/http.rb/master/logo.png)

[![Gem Version](https://badge.fury.io/rb/http.svg)](https://rubygems.org/gems/http)
[![Build Status](https://secure.travis-ci.org/httprb/http.svg?branch=master)](https://travis-ci.org/httprb/http)
[![Code Climate](https://codeclimate.com/github/httprb/http.svg?branch=master)](https://codeclimate.com/github/httprb/http)
[![Coverage Status](https://coveralls.io/repos/httprb/http/badge.svg?branch=master)](https://coveralls.io/r/httprb/http)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/httprb/http/blob/master/LICENSE.txt)

_NOTE: This is the 3.x **development** branch.  For the 2.x **stable** branch, please see:_

https://github.com/httprb/http/tree/2-x-stable

## About

HTTP (The Gem! a.k.a. http.rb) is an easy-to-use client library for making requests
from Ruby. It uses a simple method chaining system for building requests, similar to
Python's [Requests].

Under the hood, http.rb uses [http_parser.rb], a fast HTTP parsing native
extension based on the Node.js parser and a Java port thereof. This library
isn't just yet another wrapper around Net::HTTP. It implements the HTTP protocol
natively and outsources the parsing to native extensions.

[requests]: http://docs.python-requests.org/en/latest/
[http_parser.rb]: https://github.com/tmm1/http_parser.rb


## Another Ruby HTTP library? Why should I care?

There are a lot of HTTP libraries to choose from in the Ruby ecosystem.
So why would you choose this one?

Top three reasons:

1. **Clean API**: http.rb offers an easy-to-use API that should be a
   breath of fresh air after using something like Net::HTTP.

2. **Maturity**: http.rb is one of the most mature Ruby HTTP clients, supporting
   features like persistent connections and fine-grained timeouts.

3. **Performance**: using native parsers and a clean, lightweight implementation,
   http.rb achieves the best performance of any Ruby HTTP library which
   implements the HTTP protocol in Ruby instead of C:

  | HTTP client              | Time   | Implementation        |
  |--------------------------|--------|-----------------------|
  | curb (persistent)        | 2.519  | libcurl wrapper       |
  | em-http-request          | 2.731  | EM + http_parser.rb   |
  | Typhoeus                 | 2.851  | libcurl wrapper       |
  | StreamlyFFI (persistent) | 2.853  | libcurl wrapper       |
  | http.rb (persistent)     | 2.970  | Ruby + http_parser.rb |
  | http.rb                  | 3.588  | Ruby + http_parser.rb |
  | HTTParty                 | 3.931  | Net::HTTP wrapper     |
  | Net::HTTP                | 3.959  | Pure Ruby             |
  | Net::HTTP (persistent)   | 4.043  | Pure Ruby             |
  | open-uri                 | 4.479  | Net::HTTP wrapper     |
  | Excon (persistent)       | 4.618  | Pure Ruby             |
  | Excon                    | 4.701  | Pure Ruby             |
  | RestClient               | 26.838 | Net::HTTP wrapper     |

Benchmarks performed using excon's benchmarking tool

DISCLAIMER: Most benchmarks you find in READMEs are crap,
including this one. These are out-of-date. If you care about
performance, benchmark for yourself for your own use cases!

## Help and Discussion

If you need help or just want to talk about the http.rb,
visit the http.rb Google Group:

https://groups.google.com/forum/#!forum/httprb

You can join by email by sending a message to:

[httprb+subscribe@googlegroups.com](mailto:httprb+subscribe@googlegroups.com)

If you believe you've found a bug, please report it at:

https://github.com/httprb/http/issues


## Installation

Add this line to your application's Gemfile:
```ruby
gem "http"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install http
```

Inside of your Ruby program do:
```ruby
require "http"
```

...to pull it in as a dependency.


## Documentation

[Please see the http.rb wiki](https://github.com/httprb/http/wiki)
for more detailed documentation and usage notes.

The following API documentation is also available:

* [YARD API documentation](http://www.rubydoc.info/gems/http/frames)
* [Chainable module (all chainable methods)](http://www.rubydoc.info/gems/http/HTTP/Chainable)

### Basic Usage

Here's some simple examples to get you started:

```ruby
>> HTTP.get("https://github.com").to_s
=> "\n\n\n<!DOCTYPE html>\n<html lang=\"en\" class=\"\">\n  <head prefix=\"o..."
```

That's all it takes! To obtain an `HTTP::Response` object instead of the response
body, all we have to do is omit the `#to_s` on the end:

```ruby
>> HTTP.get("https://github.com")
=> #<HTTP::Response/1.1 200 OK {"Server"=>"GitHub.com", "Date"=>"Tue, 10 May...>
```

We can also obtain an `HTTP::Response::Body` object for this response:

```ruby
>> HTTP.get("https://github.com").body
=> #<HTTP::Response::Body:3ff756862b48 @streaming=false>
```

The response body can be streamed with `HTTP::Response::Body#readpartial`.
In practice, you'll want to bind the HTTP::Response::Body to a local variable
and call `#readpartial` on it repeatedly until it returns `nil`:

```ruby
>> body = HTTP.get("https://github.com").body
=> #<HTTP::Response::Body:3ff756862b48 @streaming=false>
>> body.readpartial
=> "\n\n\n<!DOCTYPE html>\n<html lang=\"en\" class=\"\">\n  <head prefix=\"o..."
>> body.readpartial
=> "\" href=\"/apple-touch-icon-72x72.png\">\n    <link rel=\"apple-touch-ic..."
# ...
>> body.readpartial
=> nil
```

## Supported Ruby Versions

This library aims to support and is [tested against][travis] the following Ruby
versions:

* Ruby 2.2.x
* Ruby 2.3.x
* Ruby 2.4.x
* JRuby 9.1.x.x

If something doesn't work on one of these versions, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby versions,
however support will only be provided for the versions listed above.

If you would like this library to support another Ruby version or
implementation, you may volunteer to be a maintainer. Being a maintainer
entails making sure all tests run and pass on that implementation. When
something breaks on your implementation, you will be responsible for providing
patches in a timely fashion. If critical issues for a particular implementation
exist at the time of a major release, support for that Ruby version may be
dropped.

[travis]: http://travis-ci.org/httprb/http


## Contributing to http.rb

* Fork http.rb on GitHub
* Make your changes
* Ensure all tests pass (`bundle exec rake`)
* Send a pull request
* If we like them we'll merge them
* If we've accepted a patch, feel free to ask for commit access!


## Copyright

Copyright (c) 2011-2017 Tony Arcieri, Alexey V. Zapparov, Erik Michaels-Ober, Zachary Anker.
See LICENSE.txt for further details.

# Redis stores for Ruby frameworks

__Redis Store__ provides a full set of stores (*Cache*, *I18n*, *Session*, *HTTP Cache*) for modern Ruby frameworks like: __Ruby on Rails__, __Sinatra__, __Rack__, __Rack::Cache__ and __I18n__. It supports object marshalling, timeouts, single or multiple nodes, and namespaces.

Please check the *README* file of each gem for usage and installation guidelines.

## Redis Installation

### Option 1: Homebrew

MacOS X users should use [Homebrew](https://github.com/mxcl/homebrew) to install Redis:

```shell
brew install redis
```

### Option 2: From Source

Download and install Redis from [the download page](http://redis.io//download) and follow the instructions.

## Running tests

```ruby
git clone git://github.com/redis-store/redis-store.git
cd redis-store
gem install bundler
bundle exec rake
```

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" ruby ci/run.rb`

## Contributors

https://github.com/redis-store/redis-store/graphs/contributors

## Versioning

The **redis-store** family of gems uses [Semantic Versioning](http://semver.org), meaning gems depending on **redis-store**
can be reliably inclusive of any version between the current and the next major. We recommend the following dependency
in your library's gemspec:

```ruby
s.add_dependency 'redis-store', '>= 1.4', '< 2'
```

## Status

[![Gem Version](https://badge.fury.io/rb/redis-store.png)](http://badge.fury.io/rb/redis-store)
[![Build Status](https://secure.travis-ci.org/redis-store/redis-store.png?branch=master)](http://travis-ci.org/redis-store/redis-store?branch=master)
[![Code Climate](https://codeclimate.com/github/redis-store/redis-store.png)](https://codeclimate.com/github/redis-store/redis-store)

## Copyright

2009 - 2013 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license.

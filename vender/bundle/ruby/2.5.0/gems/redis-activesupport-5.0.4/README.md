# Redis stores for ActiveSupport

__`redis-activesupport`__ provides a cache for __ActiveSupport__. See the main [redis-store readme](https://github.com/redis-store/redis-store) for general guidelines.

## Installation

```ruby
# Gemfile
gem 'redis-activesupport'
```

## Usage

If you are using redis-store with Rails, consider using the [redis-rails gem](https://github.com/redis-store/redis-rails) instead. For standalone usage:

```ruby
ActiveSupport::Cache.lookup_store :redis_store # { ... optional configuration ... }
```

## Running tests

```shell
gem install bundler
git clone git://github.com/redis-store/redis-activesupport.git
cd redis-activesupport
bundle install
bundle exec rake
```

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" bundle exec rake`

## Status

[![Gem Version](https://badge.fury.io/rb/redis-activesupport.png)](http://badge.fury.io/rb/redis-activesupport) 
[![Build Status](https://secure.travis-ci.org/redis-store/redis-activesupport.png?branch=master)](http://travis-ci.org/redis-store/redis-activesupport?branch=master) 
[![Code Climate](https://codeclimate.com/github/redis-store/redis-activesupport.png)](https://codeclimate.com/github/redis-store/redis-activesupport)

## Copyright

2009 - 2013 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license

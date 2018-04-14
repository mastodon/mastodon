# Redis stores for ActionPack

__`redis-actionpack`__ provides a session store for __ActionPack__, specifically for __ActionDispatch__. See the main [redis-store readme](https://github.com/redis-store/redis-store) for general guidelines.

## Installation

```ruby
# Gemfile
gem 'redis-actionpack'
```

## Usage

If you are using redis-store with Rails, consider using the [redis-rails gem](https://github.com/redis-store/redis-rails) instead. For standalone usage:

```ruby
ActionController::Base.cache_store = ActionDispatch::Session::RedisStore.new
```

## Running tests

```shell
gem install bundler
git clone git://github.com/redis-store/redis-actionpack.git
cd redis-actionpack
bundle install
bundle exec rake
```

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" bundle exec rake`

## Status

[![Gem Version](https://badge.fury.io/rb/redis-actionpack.png)](http://badge.fury.io/rb/redis-actionpack) 
[![Build Status](https://secure.travis-ci.org/redis-store/redis-actionpack.png?branch=master)](http://travis-ci.org/redis-store/redis-actionpack?branch=master) 
[![Code Climate](https://codeclimate.com/github/redis-store/redis-actionpack.png)](https://codeclimate.com/github/redis-store/redis-actionpack)

## Copyright

2009 - 2013 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license

# Redis stores for Ruby on Rails

__`redis-rails`__ provides a full set of stores (*Cache*, *Session*, *HTTP Cache*) for __Ruby on Rails__. See the main [redis-store readme](https://github.com/redis-store/redis-store) for general guidelines.

## Installation

Add the following to your Gemfile:

```ruby
gem 'redis-rails'
```

To use with Rails 4.0+, pin the gem to the latest 4.0 version:

```ruby
gem 'redis-rails', '~> 4'
```

## Usage

```ruby
# config/application.rb
config.cache_store = :redis_store, "redis://localhost:6379/0/cache", { expires_in: 90.minutes }
```

(**NOTE:** The `:expires_in` option can also be written as `:expire_in` and `:expire_after`)

Configuration values at the end are optional. If you want to use Redis as a backend for sessions, you will also need to set:

```ruby
# config/initializers/session_store.rb
MyApplication::Application.config.session_store :redis_store, servers: ["redis://localhost:6379/0/session"]
```

You can also provide a hash instead of a URL

```ruby
config.cache_store = :redis_store, {
  host: "localhost",
  port: 6379,
  db: 0,
  password: "mysecret",
  namespace: "cache"
}
```

And similarly for the session store:

```ruby
MyApplication::Application.config.session_store :redis_store, {
  servers: [
    {
      host: "localhost",
      port: 6379,
      db: 0,
      password: "mysecret",
      namespace: "session"
    },
  ],
  expire_after: 90.minutes
}
```

And if you would like to use Redis as a rack-cache backend for HTTP caching, add [`redis-rack-cache`](https://github.com/redis-store/redis-rack-cache) to your Gemfile and add:

```ruby
# config/environments/production.rb
config.action_dispatch.rack_cache = {
  metastore: "redis://localhost:6379/1/metastore",
  entitystore: "redis://localhost:6379/1/entitystore"
}
```

## Usage with Redis Sentinel

```ruby
sentinel_config = {
  url: "redis://mymaster/0",
  role: "master",
  sentinels: [{
    host: "127.0.0.1",
    port: 26379
  },{
    host: "127.0.0.1",
    port: 26380
  },{
    host: "127.0.0.1",
    port: 26381
  }]
}

# configure cache, merging opts with sentinel conf
config.cache_store = :redis_store, sentinel_config.merge(
  namespace: "cache",
  expires_in: 1.days
)

# configure sessions, setting the sentinel config as the
# servers value, merging opts with the sentinel conf.
config.session_store :redis_store, {
  servers: [
    sentinel_config.merge(
      namespace: "sessions"
    )
  ],
  expires_in: 2.days
}
```

## Running tests

```shell
gem install bundler
git clone git://github.com/redis-store/redis-rails.git
cd redis-rails
RAILS_VERSION=5.0.1 bundle install
RAILS_VERSION=5.0.1 bundle exec rake
```

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" bundle exec rake`

## Status

[![Gem Version](https://badge.fury.io/rb/redis-rails.png)](http://badge.fury.io/rb/redis-rails)
[![Build Status](https://secure.travis-ci.org/redis-store/redis-rails.png?branch=master)](http://travis-ci.org/redis-store/redis-rails?branch=master)
[![Code Climate](https://codeclimate.com/github/redis-store/redis-rails.png)](https://codeclimate.com/github/redis-store/redis-rails)

## Copyright

2009 - 2011 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license

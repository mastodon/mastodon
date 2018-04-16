# redis-rb [![Build Status][travis-image]][travis-link] [![Inline docs][inchpages-image]][inchpages-link]

[travis-image]: https://secure.travis-ci.org/redis/redis-rb.png?branch=master
[travis-link]: http://travis-ci.org/redis/redis-rb
[travis-home]: http://travis-ci.org/
[inchpages-image]: http://inch-ci.org/github/redis/redis-rb.png
[inchpages-link]: http://inch-ci.org/github/redis/redis-rb

A Ruby client library for [Redis][redis-home].

[redis-home]: http://redis.io

A Ruby client that tries to match Redis' API one-to-one, while still
providing an idiomatic interface. It features thread-safety, client-side
sharding, pipelining, and an obsession for performance.

## Upgrading from 2.x to 3.0

Please refer to the [CHANGELOG][changelog-3.0.0] for a summary of the
most important changes, as well as a full list of changes.

[changelog-3.0.0]: https://github.com/redis/redis-rb/blob/master/CHANGELOG.md#300

## Getting started

To install **redis-rb**, run the following command:

```
  gem install redis
```

Or if you are using **bundler**, add

```
  gem 'redis', '~>3.2'
```

to your `Gemfile`, and run `bundle install`

As of version 2.0 this client only targets Redis version 2.0 and higher.
You can use an older version of this client if you need to interface
with a Redis instance older than 2.0, but this is no longer supported.

You can connect to Redis by instantiating the `Redis` class:

```ruby
require "redis"

redis = Redis.new
```

This assumes Redis was started with a default configuration, and is
listening on `localhost`, port 6379. If you need to connect to a remote
server or a different port, try:

```ruby
redis = Redis.new(:host => "10.0.1.1", :port => 6380, :db => 15)
```

You can also specify connection options as a [`redis://` URL][redis-url]:

```ruby
redis = Redis.new(:url => "redis://:p4ssw0rd@10.0.1.1:6380/15")
```

[redis-url]: http://www.iana.org/assignments/uri-schemes/prov/redis

By default, the client will try to read the `REDIS_URL` environment variable
and use that as URL to connect to. The above statement is therefore equivalent
to setting this environment variable and calling `Redis.new` without arguments.

To connect to Redis listening on a Unix socket, try:

```ruby
redis = Redis.new(:path => "/tmp/redis.sock")
```

To connect to a password protected Redis instance, use:

```ruby
redis = Redis.new(:password => "mysecret")
```

The Redis class exports methods that are named identical to the commands
they execute. The arguments these methods accept are often identical to
the arguments specified on the [Redis website][redis-commands]. For
instance, the `SET` and `GET` commands can be called like this:

[redis-commands]: http://redis.io/commands

```ruby
redis.set("mykey", "hello world")
# => "OK"

redis.get("mykey")
# => "hello world"
```

All commands, their arguments and return values are documented, and
available on [rdoc.info][rdoc].

[rdoc]: http://rdoc.info/github/redis/redis-rb/

## Sentinel support

The client is able to perform automatic failovers by using [Redis
Sentinel](http://redis.io/topics/sentinel).  Make sure to run Redis 2.8+
if you want to use this feature.

To connect using Sentinel, use:

```ruby
SENTINELS = [{:host => "127.0.0.1", :port => 26380},
             {:host => "127.0.0.1", :port => 26381}]

redis = Redis.new(:url => "redis://mymaster", :sentinels => SENTINELS, :role => :master)
```

* The master name identifies a group of Redis instances composed of a master
and one or more slaves (`mymaster` in the example).

* It is possible to optionally provide a role. The allowed roles are `master`
and `slave`. When the role is `slave`, the client will try to connect to a
random slave of the specified master. If a role is not specified, the client
will connect to the master.

* When using the Sentinel support you need to specify a list of sentinels to
connect to. The list does not need to enumerate all your Sentinel instances,
but a few so that if one is down the client will try the next one. The client
is able to remember the last Sentinel that was able to reply correctly and will
use it for the next requests.

## Storing objects

Redis only stores strings as values. If you want to store an object, you
can use a serialization mechanism such as JSON:

```ruby
require "json"

redis.set "foo", [1, 2, 3].to_json
# => OK

JSON.parse(redis.get("foo"))
# => [1, 2, 3]
```

## Pipelining

When multiple commands are executed sequentially, but are not dependent,
the calls can be *pipelined*. This means that the client doesn't wait
for reply of the first command before sending the next command. The
advantage is that multiple commands are sent at once, resulting in
faster overall execution.

The client can be instructed to pipeline commands by using the
`#pipelined` method. After the block is executed, the client sends all
commands to Redis and gathers their replies. These replies are returned
by the `#pipelined` method.

```ruby
redis.pipelined do
  redis.set "foo", "bar"
  redis.incr "baz"
end
# => ["OK", 1]
```

### Executing commands atomically

You can use `MULTI/EXEC` to run a number of commands in an atomic
fashion. This is similar to executing a pipeline, but the commands are
preceded by a call to `MULTI`, and followed by a call to `EXEC`. Like
the regular pipeline, the replies to the commands are returned by the
`#multi` method.

```ruby
redis.multi do
  redis.set "foo", "bar"
  redis.incr "baz"
end
# => ["OK", 1]
```

### Futures

Replies to commands in a pipeline can be accessed via the *futures* they
emit (since redis-rb 3.0). All calls inside a pipeline block return a
`Future` object, which responds to the `#value` method. When the
pipeline has successfully executed, all futures are assigned their
respective replies and can be used.

```ruby
redis.pipelined do
  @set = redis.set "foo", "bar"
  @incr = redis.incr "baz"
end

@set.value
# => "OK"

@incr.value
# => 1
```

## Error Handling

In general, if something goes wrong you'll get an exception. For example, if
it can't connect to the server a `Redis::CannotConnectError` error will be raised.

```ruby
begin
  redis.ping
rescue Exception => e
  e.inspect
# => #<Redis::CannotConnectError: Timed out connecting to Redis on 10.0.1.1:6380>

  e.message
# => Timed out connecting to Redis on 10.0.1.1:6380
end
```

See lib/redis/errors.rb for information about what exceptions are possible.

## Timeouts

The client allows you to configure connect, read, and write timeouts.
Passing a single `timeout` option will set all three values:

```ruby
Redis.new(:timeout => 1)
```

But you can use specific values for each of them:

```ruby
Redis.new(
  :connect_timeout => 0.2,
  :read_timeout    => 1.0,
  :write_timeout   => 0.5
)
```

All timeout values are specified in seconds.

When using pub/sub, you can subscribe to a channel using a timeout as well:

```ruby
redis.subscribe_with_timeout(5, "news") do |on|
  on.message do |channel, message|
    # ...
  end
end
```

If no message is received after 5 seconds, the client will unsubscribe.


## SSL/TLS Support

This library supports natively terminating client side SSL/TLS connections
when talking to Redis via a server-side proxy such as [stunnel], [hitch],
or [ghostunnel].

To enable SSL support, pass the `:ssl => :true` option when configuring the
Redis client, or pass in `:url => "rediss://..."` (like HTTPS for Redis).
You will also need to pass in an `:ssl_params => { ... }` hash used to
configure the `OpenSSL::SSL::SSLContext` object used for the connection:

```ruby
redis = Redis.new(
  :url        => "rediss://:p4ssw0rd@10.0.1.1:6381/15",
  :ssl_params => {
    :ca_file => "/path/to/ca.crt"
  }
)
```

The options given to `:ssl_params` are passed directly to the
`OpenSSL::SSL::SSLContext#set_params` method and can be any valid attribute
of the SSL context. Please see the [OpenSSL::SSL::SSLContext documentation]
for all of the available attributes.

Here is an example of passing in params that can be used for SSL client
certificate authentication (a.k.a. mutual TLS):

```ruby
redis = Redis.new(
  :url        => "rediss://:p4ssw0rd@10.0.1.1:6381/15",
  :ssl_params => {
    :ca_file => "/path/to/ca.crt",
    :cert    => OpenSSL::X509::Certificate.new(File.read("client.crt")),
    :key     => OpenSSL::PKey::RSA.new(File.read("client.key"))
  }
)
```

[stunnel]: https://www.stunnel.org/
[hitch]: https://hitch-tls.org/
[ghostunnel]: https://github.com/square/ghostunnel
[OpenSSL::SSL::SSLContext documentation]: http://ruby-doc.org/stdlib-2.3.0/libdoc/openssl/rdoc/OpenSSL/SSL/SSLContext.html

*NOTE:* SSL is only supported by the default "Ruby" driver


## Expert-Mode Options

 - `inherit_socket: true`: disable safety check that prevents a forked child
   from sharing a socket with its parent; this is potentially useful in order to mitigate connection churn when:
    - many short-lived forked children of one process need to talk
      to redis, AND
    - your own code prevents the parent process from using the redis
      connection while a child is alive

   Improper use of `inherit_socket` will result in corrupted and/or incorrect
   responses.

## Alternate drivers

By default, redis-rb uses Ruby's socket library to talk with Redis.
To use an alternative connection driver it should be specified as option
when instantiating the client object. These instructions are only valid
for **redis-rb 3.0**. For instructions on how to use alternate drivers from
**redis-rb 2.2**, please refer to an [older README][readme-2.2.2].

[readme-2.2.2]: https://github.com/redis/redis-rb/blob/v2.2.2/README.md

### hiredis

The hiredis driver uses the connection facility of hiredis-rb. In turn,
hiredis-rb is a binding to the official hiredis client library. It
optimizes for speed, at the cost of portability. Because it is a C
extension, JRuby is not supported (by default).

It is best to use hiredis when you have large replies (for example:
`LRANGE`, `SMEMBERS`, `ZRANGE`, etc.) and/or use big pipelines.

In your Gemfile, include hiredis:

```ruby
gem "redis", "~> 3.0.1"
gem "hiredis", "~> 0.4.5"
```

When instantiating the client object, specify hiredis:

```ruby
redis = Redis.new(:driver => :hiredis)
```

### synchrony

The synchrony driver adds support for [em-synchrony][em-synchrony].
This makes redis-rb work with EventMachine's asynchronous I/O, while not
changing the exposed API. The hiredis gem needs to be available as
well, because the synchrony driver uses hiredis for parsing the Redis
protocol.

[em-synchrony]: https://github.com/igrigorik/em-synchrony

In your Gemfile, include em-synchrony and hiredis:

```ruby
gem "redis", "~> 3.0.1"
gem "hiredis", "~> 0.4.5"
gem "em-synchrony"
```

When instantiating the client object, specify synchrony:

```ruby
redis = Redis.new(:driver => :synchrony)
```

## Testing

This library is tested using [Travis][travis-home], where it is tested
against the following interpreters and drivers:

* MRI 1.8.7 (drivers: ruby, hiredis)
* MRI 1.9.3 (drivers: ruby, hiredis, synchrony)
* MRI 2.0 (drivers: ruby, hiredis, synchrony)
* MRI 2.1 (drivers: ruby, hiredis, synchrony)
* MRI 2.2 (drivers: ruby, hiredis, synchrony)
* MRI 2.3 (drivers: ruby, hiredis, synchrony)
* JRuby 1.7 (1.8 mode) (drivers: ruby)
* JRuby 1.7 (1.9 mode) (drivers: ruby)

## Contributors

(ordered chronologically with more than 5 commits, see `git shortlog -sn` for
all contributors)

* Ezra Zygmuntowicz
* Taylor Weibley
* Matthew Clark
* Brian McKinney
* Luca Guidi
* Salvatore Sanfilippo
* Chris Wanstrath
* Damian Janowski
* Michel Martens
* Nick Quaranto
* Pieter Noordhuis
* Ilya Grigorik

## Contributing

[Fork the project](https://github.com/redis/redis-rb) and send pull
requests. You can also ask for help at `#redis-rb` on Freenode.

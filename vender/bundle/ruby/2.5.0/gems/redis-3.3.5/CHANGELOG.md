# 3.3.5

* Fixed Ruby 1.8 compatibility after backporting `Redis#connection`. See #719.

# 3.3.4

* `Redis#connection` returns a hash with connection information.
  You shouldn't need to call `Redis#_client`, ever.

# 3.3.3

* Improved timeout handling after dropping Timeout module.

# 3.3.2

* Added support for SPOP with COUNT. See #628.

* Fixed connection glitches when using SSL. See #644.

# 3.3.1

* Remove usage of Timeout::timeout, refactor into using low level non-blocking writes.
  This fixes a memory leak due to Timeout creating threads on each invocation.

# 3.3.0

* Added support for SSL/TLS. Redis doesn't support SSL natively, so you still
  need to run a terminating proxy on Redis' side. See #496.

* Added `read_timeout` and `write_timeout` options. See #437, #482.

* Added support for pub/sub with timeouts. See #329.

* Added `Redis#call`, `Redis#queue` and `Redis#commit` as a more minimal API to
  the client.

* Deprecated `Redis#disconnect!` in favor of `Redis#close`.

# 3.2.2

* Added support for `ZADD` options `NX`, `XX`, `CH`, `INCR`. See #547.

* Added support for sentinel commands. See #556.

* New `:id` option allows you to identify the client against Redis. See #510.

* `Redis::Distributed` will raise when adding two nodes with the same ID.
  See #354.

# 3.2.1

* Added support for `PUBSUB` command.

* More low-level socket errors are now raised as `CannotConnectError`.

* Added `:connect_timeout` option.

* Added support for `:limit` option for `ZREVRANGEBYLEX`.

* Fixed an issue where connections become inconsistent when using Ruby's
  Timeout module outside of the client (see #501, #502).

* Added `Redis#disconnect!` as a public-API way of disconnecting the client
  (without needing to use `QUIT`). See #506.

* Fixed Sentinel support with Hiredis.

* Fixed Sentinel support when using authentication and databases.

* Improved resilience when trying to contact sentinels.

# 3.2.0

* Redis Sentinel support.

# 3.1.0

* Added debug log sanitization (#428).

* Added support for HyperLogLog commands (Redis 2.8.9, #432).

* Added support for `BITPOS` command (Redis 2.9.11, #412).

* The client will now automatically reconnect after a fork (#414).

* If you want to disable the fork-safety check and prefer to share the
  connection across child processes, you can now pass the `inherit_socket`
  option (#409).

* If you want the client to attempt to reconnect more than once, you can now
  pass the `reconnect_attempts` option (#347)

# 3.0.7

* Added method `Redis#dup` to duplicate a Redis connection.

* IPv6 support.

# 3.0.6

* Added support for `SCAN` and variants.

# 3.0.5

* Fix calling #select from a pipeline (#309).

* Added method `Redis#connected?`.

* Added support for `MIGRATE` (Redis 2.6).

* Support extended SET command (#343, thanks to @benubois).

# 3.0.4

* Ensure #watch without a block returns "OK" (#332).

* Make futures identifiable (#330).

* Fix an issue preventing STORE in a SORT with multiple GETs (#328).

# 3.0.3

* Blocking list commands (`BLPOP`, `BRPOP`, `BRPOPLPUSH`) use a socket
  timeout equal to the sum of the command's timeout and the Redis
  client's timeout, instead of disabling socket timeout altogether.

* Ruby 2.0 compatibility.

* Added support for `DUMP` and `RESTORE` (Redis 2.6).

* Added support for `BITCOUNT` and `BITOP` (Redis 2.6).

* Call `#to_s` on value argument for `SET`, `SETEX`, `PSETEX`, `GETSET`,
  `SETNX`, and `SETRANGE`.

# 3.0.2

* Unescape CGI escaped password in URL.

* Fix test to check availability of `UNIXSocket`.

* Fix handling of score = +/- infinity for sorted set commands.

* Replace array splats with concatenation where possible.

* Raise if `EXEC` returns an error.

* Passing a nil value in options hash no longer overwrites the default.

* Allow string keys in options hash passed to `Redis.new` or
  `Redis.connect`.

* Fix uncaught error triggering unrelated error (synchrony driver).

    See f7ffd5f1a628029691084de69e5b46699bb8b96d and #248.

# 3.0.1

* Fix reconnect logic not kicking in on a write error.

    See 427dbd52928af452f35aa0a57b621bee56cdcb18 and #238.

# 3.0.0

### Upgrading from 2.x to 3.0

The following items are the most important changes to review when
upgrading from redis-rb 2.x. A full list of changes can be found below.

* The methods for the following commands have changed the arguments they
  take, their return value, or both.

    * `BLPOP`, `BRPOP`, `BRPOPLPUSH`
    * `SORT`
    * `MSETNX`
    * `ZRANGE`, `ZREVRANGE`, `ZRANGEBYSCORE`, `ZREVRANGEBYSCORE`
    * `ZINCRBY`, `ZSCORE`

* The return value from `#pipelined` and `#multi` no longer contains
  unprocessed replies, but the same replies that would be returned if
  the command had not been executed in these blocks.

* The client raises custom errors on connection errors, instead of
  `RuntimeError` and errors in the `Errno` family.

### Changes

* Added support for scripting commands (Redis 2.6).

    Scripts can be executed using `#eval` and `#evalsha`. Both can
    commands can either take two arrays to specify `KEYS` and `ARGV`, or
    take a hash containing `:keys` and `:argv` to specify `KEYS` and
    `ARGV`.

    ```ruby
    redis.eval("return ARGV[1] * ARGV[2]", :argv => [2, 3])
      # => 6
    ```

    Subcommands of the `SCRIPT` command can be executed via the
    `#script` method.

    For example:

    ```ruby
    redis.script(:load, "return ARGV[1] * ARGV[2]")
      # => "58db5d365a1922f32e7aa717722141ea9c2b0cf3"
    redis.script(:exists, "58db5d365a1922f32e7aa717722141ea9c2b0cf3")
      # => true
    redis.script(:flush)
      # => "OK"
    ```

* The repository now lives at [https://github.com/redis/redis-rb](https://github.com/redis/redis-rb).
  Thanks, Ezra!

* Added support for `PEXPIRE`, `PEXPIREAT`, `PTTL`, `PSETEX`,
  `INCRYBYFLOAT`, `HINCRYBYFLOAT` and `TIME` (Redis 2.6).

* `Redis.current` is now thread unsafe, because the client itself is thread safe.

    In the future you'll be able to do something like:

    ```ruby
    Redis.current = Redis::Pool.connect
    ```

    This makes `Redis.current` actually usable in multi-threaded environments,
    while not affecting those running a single thread.

* Change API for `BLPOP`, `BRPOP` and `BRPOPLPUSH`.

    Both `BLPOP` and `BRPOP` now take a single argument equal to a
    string key, or an array with string keys, followed by an optional
    hash with a `:timeout` key. When not specified, the timeout defaults
    to `0` to not time out.

    ```ruby
    redis.blpop(["list1", "list2"], :timeout => 1.0)
    ```

    `BRPOPLPUSH` also takes an optional hash with a `:timeout` key as
    last argument for consistency. When not specified, the timeout
    defaults to `0` to not time out.

    ```ruby
    redis.brpoplpush("some_list", "another_list", :timeout => 1.0)
    ```

* When `SORT` is passed multiple key patterns to get via the `:get`
  option, it now returns an array per result element, holding all `GET`
  substitutions.

* The `MSETNX` command now returns a boolean.

* The `ZRANGE`, `ZREVRANGE`, `ZRANGEBYSCORE` and `ZREVRANGEBYSCORE` commands
  now return an array containing `[String, Float]` pairs when
  `:with_scores => true` is passed.

    For example:

    ```ruby
    redis.zrange("zset", 0, -1, :with_scores => true)
      # => [["foo", 1.0], ["bar", 2.0]]
    ```

* The `ZINCRBY` and `ZSCORE` commands now return a `Float` score instead
  of a string holding a representation of the score.

* The client now raises custom exceptions where it makes sense.

    If by any chance you were rescuing low-level exceptions (`Errno::*`),
    you should now rescue as follows:

        Errno::ECONNRESET    -> Redis::ConnectionError
        Errno::EPIPE         -> Redis::ConnectionError
        Errno::ECONNABORTED  -> Redis::ConnectionError
        Errno::EBADF         -> Redis::ConnectionError
        Errno::EINVAL        -> Redis::ConnectionError
        Errno::EAGAIN        -> Redis::TimeoutError
        Errno::ECONNREFUSED  -> Redis::CannotConnectError

* Always raise exceptions originating from erroneous command invocation
  inside pipelines and MULTI/EXEC blocks.

    The old behavior (swallowing exceptions) could cause application bugs
    to go unnoticed.

* Implement futures for assigning values inside pipelines and MULTI/EXEC
  blocks. Futures are assigned their value after the pipeline or
  MULTI/EXEC block has executed.

    ```ruby
    $redis.pipelined do
      @future = $redis.get "key"
    end

    puts @future.value
    ```

* Ruby 1.8.6 is officially not supported.

* Support `ZCOUNT` in `Redis::Distributed` (Michael Dungan).

* Pipelined commands now return the same replies as when called outside
  a pipeline.

    In the past, pipelined replies were returned without post-processing.

* Support `SLOWLOG` command (Michael Bernstein).

* Calling `SHUTDOWN` effectively disconnects the client (Stefan Kaes).

* Basic support for mapping commands so that they can be renamed on the
  server.

* Connecting using a URL now checks that a host is given.

    It's just a small sanity check, cf. #126

* Support variadic commands introduced in Redis 2.4.

# 2.2.2

* Added method `Redis::Distributed#hsetnx`.

# 2.2.1

* Internal API: Client#call and family are now called with a single array
  argument, since splatting a large number of arguments (100K+) results in a
  stack overflow on 1.9.2.

* The `INFO` command can optionally take a subcommand. When the subcommand is
  `COMMANDSTATS`, the client will properly format the returned statistics per
  command. Subcommands for `INFO` are available since Redis v2.3.0 (unstable).

* Change `IO#syswrite` back to the buffered `IO#write` since some Rubies do
  short writes for large (1MB+) buffers and some don't (see issue #108).

# 2.2.0

* Added method `Redis#without_reconnect` that ensures the client will not try
  to reconnect when running the code inside the specified block.

* Thread-safe by default. Thread safety can be explicitly disabled by passing
  `:thread_safe => false` as argument.

* Commands called inside a MULTI/EXEC no longer raise error replies, since a
  successful EXEC means the commands inside the block were executed.

* MULTI/EXEC blocks are pipelined.

* Don't disconnect on error replies.

* Use `IO#syswrite` instead of `IO#write` because write buffering is not
  necessary.

* Connect to a unix socket by passing the `:path` option as argument.

* The timeout value is coerced into a float, allowing sub-second timeouts.

* Accept both `:with_scores` _and_ `:withscores` as argument to sorted set
  commands.

* Use [hiredis](https://github.com/pietern/hiredis-rb) (v0.3 or higher) by
  requiring "redis/connection/hiredis".

* Use [em-synchrony](https://github.com/igrigorik/em-synchrony) by requiring
  "redis/connection/synchrony".

# 2.1.1

See commit log.

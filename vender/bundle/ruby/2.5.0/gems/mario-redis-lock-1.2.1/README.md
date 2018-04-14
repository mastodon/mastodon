# RedisLock

Yet another Ruby distributed lock using Redis, with emphasis in transparency.

Implements the locking algorithm described in the [Redis SET command documentation](http://redis.io/commands/set):

  * Acquire lock with `SET {{key}} {{uuid_token}} NX PX {{ms_to_expire}}`
  * Release lock with `EVAL "if redis.call('get',KEYS[1]) == ARGV[1] then return redis.call('del',KEYS[1]) else return nil end" {{key}} {{uuid_token}}`
  * Auto release lock if expires

It has the properties:

  * Mutual exclusion: At any given moment, only one client can hold a lock
  * Deadlock free: Eventually it is always possible to acquire a lock, even if the client that locked a resource crashed or gets partitioned
  * NOT fault tolerant: if the REDIS instance goes down, the lock doesn't work. For a lock wiht liveness guarantee, see [redlock-rb](https://github.com/antirez/redlock-rb), that can use multiple REDIS instances to handle the lock.


## Installation

Requirements:

  * [Redis](http://redis.io/) >= 2.6.12
  * [redis gem](https://rubygems.org/gems/redis) >= 3.0.5

The required versions are needed for the new syntax of the SET command (using NX and EX/PX).

Install from RubyGems:

    $ gem install mario-redis-lock

Or include it in your project's `Gemfile` with Bundler:

    gem 'mario-redis-lock', :require => 'redis_lock'


## Usage

Acquire the lock to `do_exclusive_stuff`:

```ruby
RedisLock.acquire do |lock|
  if lock.acquired?
    do_exclusive_stuff # you are the only process with the lock, hooray!
  else
    oh_well # timeout, some other process has the lock and didn't release it before the retry_timeout
  end
end
```

Or (equivalent)


```ruby
lock = RedisLock.new
if lock.acquire
  begin
    do_exclusive_stuff # you are the only process with the lock, hooray!
  ensure
    lock.release
  end
else
  oh_well # timeout, some other process has the lock and didn't release it before the retry_timeout
end
```

The class method `RedisLock.acquire(options, &block)` is more concise and releases the lock at the end of the block, even if `do_exclusive_stuff` raises an exception.
The second alternative is a little more flexible.

#### Detailed Usage Examples

  * [Beer Waiter](EXAMPLE_BEER_WAITER.md): Run many threads at the same time, all them try to get a beer in 3 seconds using the same lock. Some will get it, some will timeout.
  * [Dog Pile Effect](EXAMPLE_DOG_PILE_EFFECT.md): See how to implement a `fetch_with_lock` method, that works like most `Cache.fetch(key, &block)` methods out there (if value is cached in that given key, return the cached value, otherwise run the block), but only executes the block from one of the processes that share that cache, avoiding the case when the cache is invalidated and all processes execute an expensive operation at the same time.

### Options

  * **redis**: (default `Redis.new`) an instance of Redis, or an options hash to initialize an instance of Redis (see [redis gem](https://rubygems.org/gems/redis)). You can also pass anything that "quaks" like redis, for example an instance of [mock_redis](https://rubygems.org/gems/mock_redis), for testing purposes.
  * **key**: (default `"RedisLock::default"`) Redis key used for the lock. If you need multiple locks, use a different (unique) key for each lock.
  * **autorelease**: (default `10.0`) seconds to automatically release (expire) the lock after being acquired. Make sure to give enough time for your "exclusive stuff" to be executed, otherwise other processes could get the lock and start messing with the "exclusive stuff" before this one is done. The autorelease time is important, even when manually doing `lock.realease`, because the process could crash before releasing the lock. Autorelease (expiration time) guarantees that the lock will always be released.
  * **retry**: (default `true`) boolean to enable/disable consecutive acquire retries in the same `acquire` call. If true, use `retry_timeout` and `retry_sleep` to specify how long and how often should the `acquire` method block the thread (sleep) until able to get the lock.
  * **retry_timeout**: (default `10.0`) seconds before giving up before the lock is released. Note that the execution thread is put to sleep while waiting. For a non-blocking approach, set `retry` to false.
  * **retry_sleep**: (default `0.1`) seconds to sleep between retries. For example: `RedisLock.acquire(retry_timeout: 10.0, retry_sleep: 0.1){|lock| ... }` if the lock was acquired by other process and never released, will do almost 100 retries (a rerty every 0.1 seconds, plus a little extra to run the the `SET` command) during 10 seconds, and finally yield with `lock.acquired? == false`.

Options can be set to other than the defaults when calling `RedisLock.acquire`:

```ruby
RedisLock.acquire(key: 'exclusive_stuff', retry: false) do |lock|
  if lock.acquired?
    do_exclusive_stuff
  end
end
```

Or when creating a new lock instance:

```ruby
lock = RedisLock.new(key: 'exclusive_stuff', retry: false, autorelease: 0.1)
if lock.acquire
  do_exclusive_stuff_or_not
end
```

You can also configure default values with `RedisLock.configure`:

```ruby
RedisLock.configure do |defaults|
  defaults.redis = Redis.new
  defaults.key = "RedisLock::default"
  defaults.autorelease = 10.0
  defaults.retry = true
  defaults.retry_timeout = 10.0
  defaults.retry_sleep = 0.1
end
```

A good place to set defaults in a Rails app would be in an initializer like `conf/initializers/redis_lock.rb`.


## Why another Redis lock gem?

There are other Redis locks for Ruby: [redlock-rb](https://github.com/antirez/redlock-rb), [redis-mutex](https://rubygems.org/gems/redis-mutex), [mlanett-redis-lock](https://rubygems.org/gems/mlanett-redis-lock), [redis-lock](https://rubygems.org/gems/redis-lock), [jashmenn-redis-lock](https://rubygems.org/gems/jashmenn-redis-lock), [ruby_redis_lock](https://rubygems.org/gems/ruby_redis_lock), [robust-redis-lock](https://rubygems.org/gems/robust-redis-lock), [bfg-redis-lock](https://rubygems.org/gems/bfg-redis-lock), etc.

I realized I was not sure how most of them exactly work. What is exactly going on with the lock? When does it expire? How many times needs to retry? Is the thread put to sleep meanwhile?.
By the time I learned how to tell if a lock is good or not, I learned enough to write my own, making it simple but explicit, to be used with confidence in my high scale production applications.


## Contributing

1. Fork it ( http://github.com/marioizquierdo/redis-lock/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Make sure you have installed Redis in localhost:6379. The DB 15 will be used for tests (and flushed after every test).
There is a rake task to play with an example: `rake smoke_and_pass`


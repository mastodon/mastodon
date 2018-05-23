## Example: Avoid the Dog-Pile effec when invalidating some cached value

The Dog-Pile effect is a specific case of the [Thundering Herd problem](http://en.wikipedia.org/wiki/Thundering_herd_problem),
that happens when a cached value expires and suddenly too many threads try to calculate the new value at the same time.

Sometimes, the calculation takes expensive resources and it is just fine to do it from just one thread.

Assume you have a simple cache, a `fetch` function that uses a redis instance.

Without the lock:

```ruby
# Retrieve the cached value from the redis key.
# If the key is not available, execute the block
# and store the new calculated value in the redis key with an expiration time.
def fetch(redis, key, expire, &block)
  redis.get(key) or (
    val = block.call
    redis.setex(key, expire, val) if val
    val
  )
end
```

Whith this method, it is easy to optimize slow operations by caching them in Redis.
For example, if you want to do a `heavy_database_query`:

```ruby
require 'redis'
redis = Redis.new(url: "redis://:p4ssw0rd@host:6380")
expire = 60 # keep the result cached for 1 minute
key = 'heavy_query'

val = fetch redis, key, expire do
  heavy_database_query # Recalculate if not cached (SLOW)
end

puts val
```

But this fetch could block the database if executed from too many threads, because when the Redis key expires all of them will do the same "heavy_database_query" at the same time.

To avoid this problem, you can make a `fetch_with_lock` method using a `RedisLock`:

```ruby
# Retrieve the cached value from the redis key.
# If the key is not available, execute the block
# and store the new calculated value in the redis key with an expiration time.
# The block is executed with a RedisLock to avoid the dog pile effect.
# Use the following options:
#   * :retry_timeout => (default 10) Seconds to stop trying to get the value from redis or the lock.
#   * :retry_sleep => (default 0.1) Seconds to sleep (block the process) between retries.
#   * :lock_autorelease => (default same as :retry_timeout) Maximum time in seconds to execute the block. The lock is released after this, assuming that the process failed.
#   * :lock_key => (default "#{key}_lock") The key used for the lock.
def fetch_with_lock(redis, key, expire, opts={}, &block)
  # Options
  opts[:retry_timeout] ||= 10
  opts[:retry_sleep] ||= 0.1
  opts[:first_try_time] ||= Time.now # used as memory for next retries
  opts[:lock_key] ||= "#{key}_lock"
  opts[:lock_autorelease] ||= opts[:retry_timeout]

  # Try to get from redis.
  val = redis.get(key)
  return val if val

  # If not in redis, calculate the new value (block.call), but with a RedisLock.
  RedisLock.acquire({
    redis: redis,
    key: opts[:lock_key],
    autorelease: opts[:lock_autorelease],
    retry: false,
  }) do |lock|
    if lock.acquired?
      val = block.call # execute block, load/calculate heavy stuff
      redis.setex(key, expire, val) if val # store in the redis cache
    end
  end
  return val if val

  # If the lock was not available, then someone else was already re-calculating the value.
  # Just wait a little bit and try again.
  if (Time.now - opts[:first_try_time]) < opts[:retry_timeout] # unless timed out
    sleep opts[:retry_sleep]
    return fetch_with_lock(redis, key, expire, opts, &block)
  end

  # If the lock is still unavailable after the timeout, desist and return nil.
  nil
end

```

Now with this new method, is easy to do the "heavy_database_query", cached in redis and with a lock:


```ruby
require 'redis'
require 'redis_lock'
redis = Redis.new(url: "redis://:p4ssw0rd@host:6380")
expire = 60 # keep the result cached for 1 minute
key = 'heavy_query'

val = fetch_with_lock redis, key, expire, retry_timeout: 10, retry_sleep: 1 do
  heavy_database_query # Recalculate if not cached (SLOW)
end

puts val
```

In this case, the script could be executed from as many threads as we want at the same time, because the "heavy_database_query" is done only once while the other threads wait until the value is cached again or the lock is released.



## Example: Beer Waiter

In this game, everybody wants a beer but there is only one waiter to attend. Each thread is a thirsty customer, and the Redis lock is the waiter.

This example can be copy-pasted, just make sure you have redis in localhost (default `Redis.new` instance) and the mario-redis-lock gem installed.

```ruby
require 'redis_lock'

N = 15 # how many people in the bar
puts "Starting with #{N} new thirsty customers ..."
puts

RedisLock.configure do |conf|
  conf.retry_sleep = 1    # call the waiter every second
  conf.retry_timeout = 10 # wait up to 10 seconds before giving up
  conf.autorelease = 3    # the waiter will wait a maximun of 3 seconds to be "released" before giving the lock to someone else
end

# Code for a single Thread#i
def try_to_get_a_drink(i)
  name = "Thread##{i}"
  RedisLock.acquire do |lock|
    if lock.acquired?
      puts "<< #{name} gets barman's attention (lock acquired)"
      sleep 0.2 # time do decide
      beer = %w(lager pale_ale ipa stout sour)[rand 5]
      puts ".. #{name} orders a #{beer}"
      sleep 0.4 # time for the waiter to serve the beer
      puts ">> #{name} takes the #{beer} and leaves happy :)"
      puts
    else
      puts "!! #{name} is bored of waiting and leaves angry (timeout)"
    end
  end
end

# Start N threads that will be executed in parallel
threads = []
N.times(){|i| threads << Thread.new(){ try_to_get_a_drink(i) }}
threads.each{|thread| thread.join} # do not exit until all threads are done

puts "DONE"
```

It uses threads for concurrency, but you can also execute this script from different places at the same time in parallel, they share the same lock as far as they use the same Redis instance.

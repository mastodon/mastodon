require 'minitest'
require 'minitest/autorun'
require 'redis'
require_relative '../lib/redis_lock'

# Use local redis db 15 for tests
REDIS = Redis.new(db: 15)
unless REDIS.keys.empty?
  puts '[ERROR]: Redis database 15 will be used for tests but is not empty! If you are sure, run "rake flushdb" beforehand.'
  exit!
end

describe RedisLock do
  before do
    REDIS.flushdb # cleanup redis
    RedisLock.configure do |conf|
      conf.redis = REDIS # use test Redis instance
      conf.retry = false # do not retry by default, is more convenient for fast tests
    end
  end

  after do
    RedisLock.configure_restore_defaults # restore defaults
  end

  Minitest.after_run do
    REDIS.flushdb # cleanup redis
  end


  describe ".configure" do
    it "changes the defaults" do
      RedisLock.configure do |conf|
        conf.key = "mykey"
        conf.autorelease = 11
        conf.retry = true
        conf.retry_timeout = 11
        conf.retry_sleep = 11
      end
      lock = RedisLock.new
      lock.key.must_equal "mykey"
      lock.autorelease.must_equal 11
      lock.retry.must_equal true
      lock.retry_timeout.must_equal 11
      lock.retry_sleep.must_equal 11
    end
    it "raises an error if setting an invalid option" do
      proc do
        RedisLock.configure do |conf|
          conf.nonexistingattr = "blabla"
        end
      end.must_raise NoMethodError
    end
  end

  describe ".acquire" do
    describe "with bad redis connection" do
      it "raises a Redis::CannotConnectError" do
        proc {
          RedisLock.acquire(redis: {url: "redis://localhost:1111/15"}){|lock| }
        }.must_raise Redis::CannotConnectError
      end
    end

    it "holds the lock" do
      RedisLock.acquire do |lock|
        lock.acquired?.must_equal true
        RedisLock.acquire do |lock|
          lock.acquired?.must_equal false
        end
      end
    end
    it "releases the lock at the end of the block" do
      RedisLock.acquire do |lock|
        lock.acquired?.must_equal true
      end
      RedisLock.acquire do |lock|
        lock.acquired?.must_equal true
      end
    end
    it "overrides the default config with passed options" do
      RedisLock.acquire(key: 'override', autorelease: 5555) do |lock|
        lock.key.must_equal 'override'
        lock.autorelease.must_equal 5555
      end
    end
    it "does not allow to pass a block with no |lock|" do
      proc {
        RedisLock.acquire(){ puts "I should not have been printed" }
      }.must_raise ArgumentError, "You should use lock"
    end
  end

  describe "initialize" do
    it "uses conf as default values" do
      RedisLock.configure do |conf|
        conf.key = "mykey"
        conf.autorelease = 111
      end
      lock = RedisLock.new
      lock.key.must_equal "mykey"
      lock.autorelease.must_equal 111
    end
    it "uses options to set values different than the defaults" do
      RedisLock.configure do |conf|
        conf.key = "mykey"
        conf.autorelease = 111
      end
      lock = RedisLock.new(key: 'override', autorelease: 5555)
      lock.key.must_equal 'override'
      lock.autorelease.must_equal 5555
    end
    it "initializes a lock that is not acquired" do
      lock = RedisLock.new
      lock.acquired?.must_equal false
    end
    it "raises an ArgumentError if using invalid options" do
      proc do
        RedisLock.new(nonexistingattr: "blabla")
      end.must_raise ArgumentError
    end
  end

  describe "#acquire" do
    describe "with bad redis connection" do
      it "raises a Redis::CannotConnectError" do
        proc do
          lock = RedisLock.new(redis: {url: "redis://localhost:1111/15"})
          lock.acquire
        end.must_raise Redis::CannotConnectError
      end
    end

    it "holds the lock and returs true if acquired" do
      lock1 = RedisLock.new
      lock1.acquire.must_equal true
      lock1.acquired?.must_equal true

      lock2 = RedisLock.new
      lock2.acquire.must_equal false # already acquired by lock1
      lock2.acquired?.must_equal false
    end

    it "holds the lock in the specified key" do
      RedisLock.new(key: 'key1').acquire.must_equal true
      RedisLock.new(key: 'key1').acquire.must_equal false # same key1, already in use
      RedisLock.new(key: 'key2').acquire.must_equal true # key2 is free
      RedisLock.new(key: 'key2').acquire.must_equal false # but not anymore
    end

    it "sets autorelease expiration time" do
      RedisLock.configure do |conf|
        conf.autorelease = 0.005
      end

      RedisLock.new.acquire.must_equal true
      RedisLock.new.acquire.must_equal false # already acquired
      sleep 0.010
      RedisLock.new.acquire.must_equal true # autoreleased
      RedisLock.new.acquire.must_equal false # already acquired
      RedisLock.new.acquire.must_equal false # already acquired
      sleep 0.010
      RedisLock.new.acquire.must_equal true # autoreleased again
    end

    it "retries with retry, retry_timeout and retry_sleep" do
      RedisLock.new.acquire # locked to make next acquisitions fail, to force them use the retries

      # No retries if retry: false
      lock = RedisLock.new(retry: false)
      lock.acquire.must_equal false
      lock.last_acquire_retries.must_equal 0

      # Number of retries depends on retry_sleep
      lock = RedisLock.new(retry: true, retry_timeout: 0.03, retry_sleep: 0.01)
      lock.acquire.must_equal false
      lock.last_acquire_retries.must_be_within_delta 2, 1 # it should around 1..3 retries

      # Number with less retry_sleep time, there should be more retries
      lock = RedisLock.new(retry: true, retry_timeout: 0.03, retry_sleep: 0.001)
      lock.acquire.must_equal false
      lock.last_acquire_retries.must_be_within_delta 20, 10 # it should around 10..30 retries

      # retry_timeout stops execution
      time = Time.now
      lock = RedisLock.new(retry: true, retry_timeout: 0.03, retry_sleep: 0.01) # small retry_sleep should allow for many more retries
      lock.acquire.must_equal false
      (Time.now - time).must_be_within_delta 0.03, 0.01

      # If the lock becomes available, it stops retrying
      time = Time.now
      lock = RedisLock.new(key: 'key2', autorelease: 0.03)
      lock.acquire.must_equal true
      lock2 = RedisLock.new(key: 'key2', retry: true, retry_timeout: 1, retry_sleep: 0.01)
      lock2.acquire.must_equal true # it was able to get it after it was autoreleased
      lock2.last_acquire_retries.must_be_within_delta 2, 1 # only a few retries because it was available righ after expired
      (Time.now - time).must_be_within_delta 0.03, 0.01
    end
  end

  describe "#release" do
    it 'releases the lock and returns :success' do
      lock  = RedisLock.new
      lock2 = RedisLock.new

      lock.acquire.must_equal true
      lock2.acquire.must_equal false

      lock.release.must_equal :success
      lock2.acquire.must_equal true
      lock.acquire.must_equal false

      lock2.release.must_equal :success
      lock.acquire.must_equal true
    end

    it 'returns :not_acquired if the lock is not acquired first' do
      lock  = RedisLock.new
      lock.acquired?.must_equal false
      lock.release.must_equal :not_acquired
      lock.acquire.must_equal true
      lock.acquired?.must_equal true
      lock.release.must_equal :success
      lock.acquired?.must_equal false
      lock.release.must_equal :not_acquired # we don't hold the lock anymore
    end

    it 'returns :already_released if the lock expired before releasing it' do
      lock = RedisLock.new(autorelease: 0.001)
      lock.acquire.must_equal true
      sleep 0.002
      lock.release.must_equal :already_released
      lock.acquired?.must_equal false
    end

    it 'returns :already_released if the lock expired, and does not remove it from any process that might be using the lock' do
      lock = RedisLock.new(autorelease: 0.001)
      lock.acquire.must_equal true
      sleep 0.002
      lock2 = RedisLock.new
      lock2.acquire.must_equal true # now the lock is owned by lock2

      lock.release.must_equal :already_released # lock releases
      lock.acquired?.must_equal false

      lock2.acquired?.must_equal true # but lock2 still holds the lock
      RedisLock.new.acquire.must_equal false
      RedisLock.new.acquire.must_equal false # that is why the lock can not be acquired by others

      lock2.release.must_equal :success # once lock2 releases
      RedisLock.new.acquire.must_equal true # others can finally get the lock
    end
  end
end
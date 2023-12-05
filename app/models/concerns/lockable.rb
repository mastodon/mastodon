# frozen_string_literal: true

module Lockable
  # @param [String] lock_name
  # @param [ActiveSupport::Duration] autorelease Automatically release the lock after this time
  # @param [Boolean] raise_on_failure Raise an error if a lock cannot be acquired, or fail silently
  # @raise [Mastodon::RaceConditionError]
  def with_redis_lock(lock_name, autorelease: 15.minutes, raise_on_failure: true)
    with_redis do |redis|
      RedisLock.acquire(redis: redis, key: "lock:#{lock_name}", autorelease: autorelease.seconds) do |lock|
        if lock.acquired?
          yield
        elsif raise_on_failure
          raise Mastodon::RaceConditionError, "Could not acquire lock for #{lock_name}, try again later"
        end
      end
    end
  end
end

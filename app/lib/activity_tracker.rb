# frozen_string_literal: true

class ActivityTracker
  EXPIRE_AFTER = 90.days.seconds

  class << self
    def increment(prefix)
      key = [prefix, Date.today.cweek].join(':')

      redis.incrby(key, 1)
      redis.expire(key, EXPIRE_AFTER)
    end

    def record(prefix, value)
      key = [prefix, Date.today.cweek].join(':')

      redis.pfadd(key, value)
      redis.expire(key, value)
    end

    private

    def redis
      Redis.current
    end
  end
end

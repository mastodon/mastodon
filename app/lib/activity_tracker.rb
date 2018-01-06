# frozen_string_literal: true

class ActivityTracker
  EXPIRE_AFTER = 90.days.seconds

  class << self
    def increment(prefix)
      key = [prefix, current_week].join(':')

      redis.incrby(key, 1)
      redis.expire(key, EXPIRE_AFTER)
    end

    def record(prefix, value)
      key = [prefix, current_week].join(':')

      redis.pfadd(key, value)
      redis.expire(key, EXPIRE_AFTER)
    end

    private

    def redis
      Redis.current
    end

    def current_week
      Time.zone.today.cweek
    end
  end
end

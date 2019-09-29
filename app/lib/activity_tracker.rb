# frozen_string_literal: true

class ActivityTracker
  EXPIRE_AFTER = 90.days.seconds
  EXPIRE_AFTER_MONTH = 6.months.seconds

  class << self
    include Redisable

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

    def record_month(prefix, value)
      key = [prefix, current_month].join(':')

      redis.pfadd(key, value)
      redis.expire(key, EXPIRE_AFTER_MONTH)
    end

    private

    def current_week
      Time.zone.today.cweek
    end

    def current_month
      Time.zone.today.month
    end
  end
end

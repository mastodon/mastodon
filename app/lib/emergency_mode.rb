# frozen_string_literal: true

class EmergencyMode
  class << self
    include Redisable

    def reason
      with_redis do |redis|
        redis.get('emergency_mode')
      end
    end

    def remaining_seconds
      with_redis do |redis|
        redis.ttl('emergency_mode')
      end
    end

    def enabled?
      reason.present?
    end

    def enable!(reason, expires_in = 10.minutes)
      with_redis do |redis|
        redis.set('emergency_mode', reason, ex: expires_in.to_i)
      end
    end

    def disable!
      with_redis do |redis|
        redis.del('emergency_mode')
      end
    end
  end
end

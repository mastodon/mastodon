# frozen_string_literal: true

class TrendingTags
  EXPIRE_HISTORY_AFTER = 7.days.seconds

  class << self
    def record_use!(tag, account, at_time = Time.now.utc)
      return if disallowed_hashtags.include?(tag.name) || account.silenced? || account.bot?

      increment_historical_use!(tag.id, at_time)
      increment_unique_use!(tag.id, account.id, at_time)
    end

    private

    def increment_historical_use!(tag_id, at_time)
      key = "activity:tags:#{tag_id}:#{at_time.beginning_of_day.to_i}"
      redis.incrby(key, 1)
      redis.expire(key, EXPIRE_HISTORY_AFTER)
    end

    def increment_unique_use!(tag_id, account_id, at_time)
      key = "activity:tags:#{tag_id}:#{at_time.beginning_of_day.to_i}:accounts"
      redis.pfadd(key, account_id)
      redis.expire(key, EXPIRE_HISTORY_AFTER)
    end

    def disallowed_hashtags
      return @disallowed_hashtags if defined?(@disallowed_hashtags)

      @disallowed_hashtags = Setting.disallowed_hashtags.nil? ? [] : Setting.disallowed_hashtags
      @disallowed_hashtags = @disallowed_hashtags.split(' ') if @disallowed_hashtags.is_a? String
      @disallowed_hashtags = @disallowed_hashtags.map(&:downcase)
    end

    def redis
      Redis.current
    end
  end
end

# frozen_string_literal: true

module Friends
  module AvatarUpdateObserver
    extend ActiveSupport::Concern

    REDIS_FORMAT = "account:%s:updated_at:avatar".freeze

    included do
      after_validation :set_redis_is_updated_avatar
    end

    private

    def set_redis_is_updated_avatar
      ttl = Friends::ProfileEmojiExtension::PROFILE_EMOJI_CACHE_TTL
      redis.setex(REDIS_FORMAT % username, ttl, Time.now.utc.to_i)
    end

    def redis
      Redis.current
    end
  end
end

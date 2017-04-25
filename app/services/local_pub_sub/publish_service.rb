# frozen_string_literal: true

class LocalPubSub::PublishService < BaseService
  def call(channel, message)
    prefix = ENV.fetch('REDIS_PUBSUB_PREFIX') { '' }
    redis.publish("#{prefix}#{channel}", message)
  end

  def redis
    Redis.current
  end
end

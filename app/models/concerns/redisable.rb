# frozen_string_literal: true

module Redisable
  def redis
    Thread.current[:redis] ||= RedisConnection.pool.checkout
  end

  def with_redis(&block)
    RedisConnection.with(&block)
  end
end

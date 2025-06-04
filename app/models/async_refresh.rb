# frozen_string_literal: true

class AsyncRefresh
  extend Redisable
  include Redisable

  def self.find(id)
    redis_key = Rails.application.message_verifier('async_refreshes').verify(id)
    new(redis_key) if redis.exists?(redis_key)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def initialize(redis_key)
    @redis_key = redis_key
  end

  def id
    Rails.application.message_verifier('async_refreshes').generate(@redis_key)
  end

  def status
    redis.hget(@redis_key, 'status')
  end

  def result_count
    redis.hget(@redis_key, 'result_count')&.to_i
  end

  def to_json(_options)
    {
      async_refresh: {
        id:,
        status:,
        result_count:,
      },
    }.to_json
  end
end

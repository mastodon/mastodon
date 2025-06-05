# frozen_string_literal: true

class AsyncRefresh
  extend Redisable
  include Redisable

  NEW_REFRESH_EXPIRATION = 1.day
  FINISHED_REFRESH_EXPIRATION = 1.hour

  def self.find(id)
    redis_key = Rails.application.message_verifier('async_refreshes').verify(id)
    new(redis_key) if redis.exists?(redis_key)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def self.create(redis_key, count_results: false)
    data = { 'status' => 'running' }
    data['result_count'] = 0 if count_results
    redis.hset(redis_key, data)
    redis.expire(redis_key, NEW_REFRESH_EXPIRATION)
    new(redis_key)
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

  def running?
    status == 'running'
  end

  def finished?
    status == 'finished'
  end

  def finish!
    redis.hset(@redis_key, { 'status' => 'finished' })
    redis.expire(@redis_key, FINISHED_REFRESH_EXPIRATION)
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

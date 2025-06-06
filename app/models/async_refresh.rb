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

  def self.exists?(redis_key)
    redis.exists?(redis_key)
  end

  attr_reader :status, :result_count

  def initialize(redis_key)
    @redis_key = redis_key
    fetch_data_from_redis
  end

  def id
    Rails.application.message_verifier('async_refreshes').generate(@redis_key)
  end

  def running?
    @status == 'running'
  end

  def finished?
    @status == 'finished'
  end

  def finish!
    redis.pipelined do |pipeline|
      pipeline.hset(@redis_key, { 'status' => 'finished' })
      pipeline.expire(@redis_key, FINISHED_REFRESH_EXPIRATION)
    end
    @status = 'finished'
  end

  def increment_result_count(by: 1)
    redis.hincrby(@redis_key, 'result_count', by)
    fetch_data_from_redis
  end

  def reload
    fetch_data_from_redis
    self
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

  private

  def fetch_data_from_redis
    @status, @result_count = redis.pipelined do |pipeline|
      pipeline.hget(@redis_key, 'status')
      pipeline.hget(@redis_key, 'result_count')
    end
    @result_count = @result_count.presence&.to_i
  end
end

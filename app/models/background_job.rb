# frozen_string_literal: true

class BackgroundJob
  extend Redisable
  include Redisable

  def self.find(id)
    redis_key = Rails.application.message_verifier('background_jobs').verify(id)
    new(redis_key) if redis.exists?(redis_key)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def initialize(redis_key)
    @redis_key = redis_key
  end

  def id
    Rails.application.message_verifier('background_jobs').generate(@redis_key)
  end

  def status
    redis.hget(@redis_key, 'status')
  end

  def result_count
    redis.hget(@redis_key, 'result_count')&.to_i
  end

  def to_json(_options)
    {
      background_job: {
        id:,
        status:,
        result_count:,
      },
    }.to_json
  end
end

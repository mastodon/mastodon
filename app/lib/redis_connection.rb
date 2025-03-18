# frozen_string_literal: true

class RedisConnection
  class << self
    def establish_pool(new_pool_size, config)
      @pool&.shutdown(&:close)
      @pool = ConnectionPool.new(size: new_pool_size) { new(config).connection }
    end

    delegate :with, to: :pool

    def pool
      @pool ||= establish_pool(pool_size, REDIS_CONFIGURATION.base)
    end

    def streaming_pool
      @pool ||= establish_pool(2, REDIS_CONFIGURATION.streaming)
    end

    def pool_size
      if Sidekiq.server?
        Sidekiq[:concurrency]
      else
        ENV['MAX_THREADS'] || 5
      end
    end
  end

  attr_reader :config

  def initialize(config)
    @config = config
  end

  def connection
    namespace = config[:namespace]
    if namespace.present?
      Redis::Namespace.new(namespace, redis: raw_connection)
    else
      raw_connection
    end
  end

  private

  def raw_connection
    Redis.new(**config)
  end
end

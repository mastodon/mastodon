# frozen_string_literal: true

class RedisConnection
  class << self
    def establish_pool(new_pool_size)
      @pool&.shutdown(&:close)
      @pool = ConnectionPool.new(size: new_pool_size) { new.connection }
    end

    delegate :with, to: :pool

    def pool
      @pool ||= establish_pool(pool_size)
    end

    def pool_size
      if Sidekiq.server?
        Sidekiq.default_configuration[:concurrency]
      else
        ENV['MAX_THREADS'] || 5
      end
    end
  end

  attr_reader :config

  def initialize
    @config = REDIS_CONFIGURATION.base
  end

  def connection
    raw_connection
  end

  private

  def raw_connection
    Redis.new(**config)
  end
end

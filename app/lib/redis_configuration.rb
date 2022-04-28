# frozen_string_literal: true

class RedisConfiguration
  class << self
    def with
      pool.with { |redis| yield redis }
    end

    def pool
      @pool ||= ConnectionPool.new(size: pool_size) { new.connection }
    end

    def pool_size
      if Sidekiq.server?
        Sidekiq.options[:concurrency]
      else
        ENV['MAX_THREADS'] || 5
      end
    end
  end

  def connection
    if namespace?
      Redis::Namespace.new(namespace, redis: raw_connection)
    else
      raw_connection
    end
  end

  def namespace?
    namespace.present?
  end

  def namespace
    ENV.fetch('REDIS_NAMESPACE', nil)
  end

  def url
    ENV['REDIS_URL']
  end

  private

  def raw_connection
    Redis.new(url: url, driver: :hiredis)
  end
end

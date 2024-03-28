# frozen_string_literal: true

class RedisConfiguration
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
        Sidekiq[:concurrency]
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
    if ENV['REDIS_SENTINEL']
      m = ENV.fetch('REDIS_SENTINEL_MASTER', 'mymaster')
      p = ENV.fetch('REDIS_PASSWORD', '')
      "redis://:#{p}@#{m}"
    else
      ENV['REDIS_URL']
    end
  end

  def sentinels
    return unless ENV['REDIS_SENTINEL']

    unless ENV['REDIS_SENTINEL'].include? ','
      ips = Resolv.getaddresses(ENV['REDIS_SENTINEL'])
      port = ENV.fetch('REDIS_SENTINEL_PORT', '26379')

      ENV['REDIS_SENTINEL'] = ips.map do |ip|
        "#{ip}:#{port}"
      end.join(',')
    end
    ENV['REDIS_SENTINEL'].split(',').map do |server|
      host, port = server.split(':')
      { host: host, port: port.to_i }
    end
  end

  def master_name
    ENV.fetch('REDIS_SENTINEL_MASTER', 'mymaster')
  end

  def sentinel_mode?
    ENV.include? 'REDIS_SENTINEL'
  end

  private

  def raw_connection
    if sentinel_mode?
      Redis.new(url: url, driver: :hiredis, sentinels: sentinels, master_name: master_name)
    else
      Redis.new(url: url, driver: :hiredis)
    end
  end
end

# frozen_string_literal: true

class Mastodon::RedisConfiguration
  def base
    @base ||= {
      url: setup_base_redis_url,
      driver: driver,
      namespace: base_namespace,
    }
  end

  def sidekiq
    @sidekiq ||= {
      url: setup_prefixed_redis_url(:sidekiq),
      driver: driver,
      namespace: sidekiq_namespace,
    }
  end

  def cache
    @cache ||= {
      url: setup_prefixed_redis_url(:cache),
      driver: driver,
      namespace: cache_namespace,
      expires_in: 10.minutes,
      connect_timeout: 5,
      pool: {
        size: Sidekiq.server? ? Sidekiq[:concurrency] : Integer(ENV['MAX_THREADS'] || 5),
        timeout: 5,
      },
    }
  end

  private

  def driver
    ENV['REDIS_DRIVER'] == 'ruby' ? :ruby : :hiredis
  end

  def namespace
    @namespace ||= ENV.fetch('REDIS_NAMESPACE', nil)
  end

  def base_namespace
    return "mastodon_test#{ENV.fetch('TEST_ENV_NUMBER', nil)}" if Rails.env.test?

    namespace
  end

  def sidekiq_namespace
    namespace
  end

  def cache_namespace
    namespace ? "#{namespace}_cache" : 'cache'
  end

  def setup_base_redis_url
    url = ENV.fetch('REDIS_URL', nil)
    return url if url.present?

    user     = ENV.fetch('REDIS_USER', '')
    password = ENV.fetch('REDIS_PASSWORD', '')
    host     = ENV.fetch('REDIS_HOST', 'localhost')
    port     = ENV.fetch('REDIS_PORT', 6379)
    db       = ENV.fetch('REDIS_DB', 0)

    construct_uri(host, port, db, user, password)
  end

  def setup_prefixed_redis_url(prefix)
    prefix = "#{prefix.to_s.upcase}_"
    url = ENV.fetch("#{prefix}REDIS_URL", nil)

    return url if url.present?

    user     = ENV.fetch("#{prefix}REDIS_USER", nil)
    password = ENV.fetch("#{prefix}REDIS_PASSWORD", nil)
    host     = ENV.fetch("#{prefix}REDIS_HOST", nil)
    port     = ENV.fetch("#{prefix}REDIS_PORT", nil)
    db       = ENV.fetch("#{prefix}REDIS_DB", nil)

    if host.nil?
      base[:url]
    else
      construct_uri(host, port, db, user, password)
    end
  end

  def construct_uri(host, port, db, user, password)
    Addressable::URI.parse("redis://#{host}:#{port}/#{db}").tap do |uri|
      uri.user = user if user.present?
      uri.password = password if password.present?
    end.normalize.to_str
  end
end

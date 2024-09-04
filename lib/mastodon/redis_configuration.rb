# frozen_string_literal: true

class Mastodon::RedisConfiguration
  DEFAULTS = {
    host: 'localhost',
    port: 6379,
    db: 0,
  }.freeze

  def base
    @base ||= setup_config(prefix: nil, defaults: DEFAULTS)
              .merge(namespace: base_namespace)
  end

  def sidekiq
    @sidekiq ||= setup_config(prefix: 'SIDEKIQ_')
                 .merge(namespace: sidekiq_namespace)
  end

  def cache
    @cache ||= setup_config(prefix: 'CACHE_')
               .merge({
                 namespace: cache_namespace,
                 expires_in: 10.minutes,
                 connect_timeout: 5,
                 pool: {
                   size: Sidekiq.server? ? Sidekiq[:concurrency] : Integer(ENV['MAX_THREADS'] || 5),
                   timeout: 5,
                 },
               })
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

  def setup_config(prefix: nil, defaults: {})
    prefix = "#{prefix}REDIS_"

    url       = ENV.fetch("#{prefix}URL", nil)
    user      = ENV.fetch("#{prefix}USER", nil)
    password  = ENV.fetch("#{prefix}PASSWORD", nil)
    host      = ENV.fetch("#{prefix}HOST", defaults[:host])
    port      = ENV.fetch("#{prefix}PORT", defaults[:port])
    db        = ENV.fetch("#{prefix}DB", defaults[:db])
    name      = ENV.fetch("#{prefix}SENTINEL_MASTER", nil)
    sentinels = parse_sentinels(ENV.fetch("#{prefix}SENTINELS", nil))

    return { url:, driver: } if url

    if name.present? && sentinels.present?
      host = name
      port = nil
      db ||= 0
    else
      sentinels = nil
    end

    url = construct_uri(host, port, db, user, password)

    if url.present?
      { url:, driver:, name:, sentinels: }
    else
      # Fall back to base config. This has defaults for the URL
      # so this cannot lead to an endless loop.
      base
    end
  end

  def construct_uri(host, port, db, user, password)
    return nil if host.blank?

    Addressable::URI.parse("redis://#{host}:#{port}/#{db}").tap do |uri|
      uri.user = user if user.present?
      uri.password = password if password.present?
    end.normalize.to_str
  end

  def parse_sentinels(sentinels_string)
    (sentinels_string || '').split(',').map do |sentinel|
      host, port = sentinel.split(':')
      port = port.present? ? port.to_i : 26_379
      { host: host, port: port }
    end.presence
  end
end

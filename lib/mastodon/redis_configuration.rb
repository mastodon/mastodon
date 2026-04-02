# frozen_string_literal: true

class Mastodon::RedisConfiguration
  DEFAULTS = {
    host: 'localhost',
    port: 6379,
    db: 0,
  }.freeze

  def base
    @base ||= setup_config(prefix: nil, defaults: DEFAULTS)
  end

  def sidekiq
    @sidekiq ||= setup_config(prefix: 'SIDEKIQ_')
  end

  def cache
    @cache ||= setup_config(prefix: 'CACHE_')
      .merge({
        namespace: 'cache',
        expires_in: 10.minutes,
        connect_timeout: 5,
        pool: {
          size: Sidekiq.server? ? Sidekiq.default_configuration[:concurrency] : Integer(ENV['MAX_THREADS'] || 5),
          timeout: 5,
        },
      })
  end

  private

  def driver
    ENV['REDIS_DRIVER'] == 'ruby' ? :ruby : :hiredis
  end

  def setup_config(prefix: nil, defaults: {})
    prefix = "#{prefix}REDIS_"

    url      = ENV.fetch("#{prefix}URL", nil)
    user     = ENV.fetch("#{prefix}USER", nil)
    password = ENV.fetch("#{prefix}PASSWORD", nil)
    host     = ENV.fetch("#{prefix}HOST", defaults[:host])
    port     = ENV.fetch("#{prefix}PORT", defaults[:port])
    db       = Rails.env.test? ? ENV.fetch('TEST_ENV_NUMBER', defaults[:db]).to_i + 1 : ENV.fetch("#{prefix}DB", defaults[:db])

    return { url:, driver: } if url

    sentinel_options = setup_sentinels(prefix, default_user: user, default_password: password)

    if sentinel_options.present?
      host = sentinel_options[:name]
      port = nil
      db ||= 0
    end

    url = construct_uri(host, port, db, user, password)

    if url.present?
      { url:, driver: }.merge(sentinel_options)
    else
      # Fall back to base config, which has defaults for the URL
      # so this cannot lead to endless recursion.
      base
    end
  end

  def setup_sentinels(prefix, default_user: nil, default_password: nil)
    name              = ENV.fetch("#{prefix}SENTINEL_MASTER", nil)
    sentinel_port     = ENV.fetch("#{prefix}SENTINEL_PORT", 26_379)
    sentinel_list     = ENV.fetch("#{prefix}SENTINELS", nil)
    sentinel_username = ENV.fetch("#{prefix}SENTINEL_USERNAME", default_user)
    sentinel_password = ENV.fetch("#{prefix}SENTINEL_PASSWORD", default_password)

    sentinels = parse_sentinels(sentinel_list, default_port: sentinel_port)

    if name.present? && sentinels.present?
      { name:, sentinels:, sentinel_username:, sentinel_password: }
    else
      {}
    end
  end

  def construct_uri(host, port, db, user, password)
    return nil if host.blank?

    Addressable::URI.parse("redis://#{host}:#{port}/#{db}").tap do |uri|
      uri.user = user if user.present?
      uri.password = password if password.present?
    end.normalize.to_str
  end

  def parse_sentinels(sentinels_string, default_port: 26_379)
    (sentinels_string || '').split(',').map do |sentinel|
      host, port = sentinel.split(':')
      port = (port || default_port).to_i
      { host: host, port: port }
    end.presence
  end
end

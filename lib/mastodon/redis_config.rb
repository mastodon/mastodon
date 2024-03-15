# frozen_string_literal: true

def setup_redis_env_url(prefix = nil, defaults = true)
  prefix = "#{prefix.to_s.upcase}_" unless prefix.nil?
  prefix = '' if prefix.nil?

  return if ENV["#{prefix}REDIS_URL"].present?

  password = ENV.fetch("#{prefix}REDIS_PASSWORD") { '' if defaults }
  host     = ENV.fetch("#{prefix}REDIS_HOST") { 'localhost' if defaults }
  port     = ENV.fetch("#{prefix}REDIS_PORT") { 6379 if defaults }
  db       = ENV.fetch("#{prefix}REDIS_DB") { 0 if defaults }

  ENV["#{prefix}REDIS_URL"] = begin
    if [password, host, port, db].all?(&:nil?)
      ENV['REDIS_URL']
    else
      Addressable::URI.parse("redis://#{host}:#{port}/#{db}").tap do |uri|
        uri.password = password if password.present?
      end.normalize.to_str
    end
  end

  return unless ENV["#{prefix}REDIS_SENTINEL"] || ENV['REDIS_SENTINEL']

  ENV["#{prefix}REDIS_SENTINEL"] = ENV["#{prefix}REDIS_SENTINEL"] || ENV['REDIS_SENTINEL']

  sentinel_master = ENV.fetch("#{prefix}REDIS_SENTINEL_MASTER", 'mymaster')
  password = ENV["#{prefix}REDIS_PASSWORD"] || ENV.fetch('REDIS_PASSWORD')

  unless ENV["#{prefix}REDIS_SENTINEL"].include? ','
    ips = Resolv.getaddresses(ENV["#{prefix}REDIS_SENTINEL"])
    port = ENV.fetch("#{prefix}REDIS_SENTINEL_PORT", '26379')

    ENV["#{prefix}REDIS_SENTINEL"] = ips.map do |ip|
      "#{ip}:#{port}"
    end.join(',').concat(',')
  end

  ENV["#{prefix}REDIS_URL"] = "redis://:#{password}@#{sentinel_master}"
end

setup_redis_env_url
setup_redis_env_url(:cache, false)
setup_redis_env_url(:sidekiq, false)

namespace         = ENV.fetch('REDIS_NAMESPACE', nil)
cache_namespace   = namespace ? "#{namespace}_cache" : 'cache'
sidekiq_namespace = namespace

REDIS_CACHE_PARAMS = {
  driver: :hiredis,
  url: ENV['CACHE_REDIS_URL'],
  expires_in: 10.minutes,
  namespace: "#{cache_namespace}:7.1",
  connect_timeout: 5,
  pool: {
    size: Sidekiq.server? ? Sidekiq[:concurrency] : Integer(ENV['MAX_THREADS'] || 5),
    timeout: 5,
  },

  master_name: (ENV.fetch('CACHE_REDIS_SENTINEL_MASTER', 'mymaster') if ENV['CACHE_REDIS_SENTINEL']),
  sentinels: (if ENV['CACHE_REDIS_SENTINEL']
                ENV['CACHE_REDIS_SENTINEL'].split(',').map do |server|
                  host, port = server.split(':')
                  { host: host, port: port.to_i }
                end
              end),
}.freeze

REDIS_SIDEKIQ_PARAMS = {
  driver: :hiredis,
  url: ENV['SIDEKIQ_REDIS_URL'],
  namespace: sidekiq_namespace,

  master_name: (ENV.fetch('SIDEKIQ_REDIS_SENTINEL_MASTER', 'mymaster') if ENV['SIDEKIQ_REDIS_SENTINEL']),
  sentinels: (if ENV['SIDEKIQ_REDIS_SENTINEL']
                ENV['SIDEKIQ_REDIS_SENTINEL'].split(',').map do |server|
                  host, port = server.split(':')
                  { host: host, port: port.to_i }
                end
              end),
}.freeze

ENV['REDIS_NAMESPACE'] = "mastodon_test#{ENV['TEST_ENV_NUMBER']}" if Rails.env.test?

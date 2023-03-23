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
  namespace: cache_namespace,
  pool_size: Sidekiq.server? ? Sidekiq.options[:concurrency] : Integer(ENV['MAX_THREADS'] || 5),
  pool_timeout: 5,
  connect_timeout: 5,
}.freeze

REDIS_SIDEKIQ_PARAMS = {
  driver: :hiredis,
  url: ENV['SIDEKIQ_REDIS_URL'],
  namespace: sidekiq_namespace,
}.freeze

ENV['REDIS_NAMESPACE'] = "mastodon_test#{ENV['TEST_ENV_NUMBER']}" if Rails.env.test?

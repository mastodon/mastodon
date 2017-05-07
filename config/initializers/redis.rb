# frozen_string_literal: true

if ENV['REDIS_URL'].blank?
  password = ENV.fetch('REDIS_PASSWORD') { '' }
  host     = ENV.fetch('REDIS_HOST') { 'localhost' }
  port     = ENV.fetch('REDIS_PORT') { 6379 }
  db       = ENV.fetch('REDIS_DB') { 0 }

  ENV['REDIS_URL'] = "redis://#{password.blank? ? '' : ":#{password}@"}#{host}:#{port}/#{db}"
end

Redis.current = Redis.new(
  url: ENV['REDIS_URL'],
  driver: :hiredis
)

Rails.application.configure do
  config.cache_store = :redis_store, ENV['REDIS_URL'], {
    namespace: 'cache',
    expires_in: 10.minutes,
  }
end

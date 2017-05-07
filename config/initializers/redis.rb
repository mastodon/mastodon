# frozen_string_literal: true

if ENV['REDIS_URL'].blank?
  password = ENV.fetch('REDIS_PASSWORD') { '' }
  host     = ENV.fetch('REDIS_HOST') { 'localhost' }
  port     = ENV.fetch('REDIS_PORT') { 6379 }
  db       = ENV.fetch('REDIS_DB') { 0 }

  ENV['REDIS_URL'] = "redis://#{password.blank? ? '' : ":#{password}@"}#{host}:#{port}/#{db}"
end

redis_connection = Redis.new(
  url: ENV['REDIS_URL'],
  driver: :hiredis
)

cache_params = { expires_in: 10.minutes }

namespace = ENV.fetch('REDIS_NAMESPACE') { nil }
if namespace
  Redis.current = Redis::Namespace.new(namespace, :redis => redis_connection)
  cache_params[:namespace] = namespace + '_cache'
else
  Redis.current = redis_connection
end

Rails.application.configure do
  config.cache_store = :redis_store, ENV['REDIS_URL'], cache_params
end

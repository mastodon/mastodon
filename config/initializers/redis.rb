# frozen_string_literal: true

redis_params = {
  password: ENV.fetch('REDIS_PASSWORD') { false },
  host:     ENV.fetch('REDIS_HOST') { 'localhost' },
  port:     ENV.fetch('REDIS_PORT') { 6379 },
  db:       ENV.fetch('REDIS_DB') { 0 },
  driver:   :hiredis
}

redis_connection = Redis.new(redis_params)

cache_params = { expires_in: 10.minutes }

namespace = ENV.fetch('REDIS_NAMESPACE') { nil }
if namespace
  Redis.current = Redis::Namespace.new(namespace, :redis => redis_connection)
  cache_params[:namespace] = namespace + '_cache'
else
  Redis.current = redis_connection
end

Rails.application.configure do
  config.cache_store = :redis_store, redis_params, cache_params
end

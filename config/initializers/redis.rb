# frozen_string_literal: true

opts = {
  url: ENV['REDIS_URL'],
  driver: :hiredis
}

if ENV['REDIS_TLS_NOVERIFY']
  opts[:driver] = :ruby
  opts[:ssl_params] = { verify_mode: OpenSSL::SSL::VERIFY_NONE }
end

redis_connection = Redis.new(opts)

namespace = ENV.fetch('REDIS_NAMESPACE') { nil }

if namespace
  Redis.current = Redis::Namespace.new(namespace, redis: redis_connection)
else
  Redis.current = redis_connection
end

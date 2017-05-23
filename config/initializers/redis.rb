# frozen_string_literal: true

redis_connection = Redis.new(
  url: ENV['REDIS_URL'],
  driver: :hiredis
)

namespace = ENV.fetch('REDIS_NAMESPACE') { nil }

if namespace
  Redis.current = Redis::Namespace.new(namespace, redis: redis_connection)
else
  Redis.current = redis_connection
end

# TODO: Read from ENV?
vapid_key = Webpush.generate_key

# TODO: Store somewhere else?
Redis.current.set('vapid_public_key', vapid_key.public_key)
Redis.current.set('vapid_private_key', vapid_key.private_key)

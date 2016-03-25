redis_conn = proc {
  $redis.dup
}

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 5, &redis_conn)
end

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 25, &redis_conn)
end

if ENV['REDIS_NAMESPACE']
  Sidekiq.configure_server { |c| c.redis = { namespace: ENV['REDIS_NAMESPACE'] } }
  Sidekiq.configure_client { |c| c.redis = { namespace: ENV['REDIS_NAMESPACE'] } }
end

redis_config = if ENV['REDIS_SOCKET']
  { 
    url: "unix:#{ENV['REDIS_SOCKET']}" 
  }
else
  { 
    host: ENV.fetch('REDIS_HOST') { 'localhost' }, 
    port: ENV.fetch('REDIS_PORT') { '6379' },
    password: ENV.fetch('REDIS_PASSWORD') { false }
  }
end
redis_config[:db] = ENV.fetch('REDIS_DB') { 0 }

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

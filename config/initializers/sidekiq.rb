host = ENV.fetch('REDIS_HOST') { 'localhost' }
port = ENV.fetch('REDIS_PORT') { 6379 }

Sidekiq.configure_server do |config|
  config.redis = { host: host, port: port }
end

Sidekiq.configure_client do |config|
  config.redis = { host: host, port: port }
end

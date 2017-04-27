host = ENV.fetch('REDIS_HOST') { 'localhost' }
port = ENV.fetch('REDIS_PORT') { 6379 }
password = ENV.fetch('REDIS_PASSWORD') { false }
db = ENV.fetch('REDIS_DB') { 0 }

Sidekiq.configure_server do |config|
  config.redis = { host: host, port: port, db: db, password: password }
end

Sidekiq.configure_client do |config|
  config.redis = { host: host, port: port, db: db, password: password }
end

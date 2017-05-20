# frozen_string_literal: true
host = ENV.fetch('REDIS_HOST') { 'localhost' }
port = ENV.fetch('REDIS_PORT') { 6379 }
password = ENV.fetch('REDIS_PASSWORD') { false }
db = ENV.fetch('REDIS_DB') { 0 }

namespace = ENV.fetch('REDIS_NAMESPACE') { nil }
redis_params = { host: host, port: port, db: db, password: password }

if namespace
  redis_params [:namespace] = namespace
end

Sidekiq.configure_server do |config|
  config.redis = redis_params
end

Sidekiq.configure_client do |config|
  config.redis = redis_params
end

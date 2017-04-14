# frozen_string_literal: true

namespace = ENV.fetch('REDIS_NAMESPACE') { '' }
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'],
                   namespace: namespace}
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'],
                   namespace: namespace }
end

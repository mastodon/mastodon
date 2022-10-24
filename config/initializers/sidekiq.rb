# frozen_string_literal: true

require_relative '../../lib/mastodon/sidekiq_middleware'
require_relative '../../lib/argument_deduplication'

Sidekiq.configure_server do |config|
  config.redis = REDIS_SIDEKIQ_PARAMS

  config.server_middleware do |chain|
    chain.add Mastodon::SidekiqMiddleware
  end

  config.server_middleware do |chain|
    chain.add ArgumentDeduplication::Server
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  config.client_middleware do |chain|
    chain.add ArgumentDeduplication::Client
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  ArgumentDeduplication.configure(config)
  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_SIDEKIQ_PARAMS

  config.client_middleware do |chain|
    chain.add ArgumentDeduplication::Client
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end

Sidekiq.logger.level = ::Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)

SidekiqUniqueJobs.configure do |config|
  config.reaper          = :ruby
  config.reaper_count    = 1000
  config.reaper_interval = 600
  config.reaper_timeout  = 150
end

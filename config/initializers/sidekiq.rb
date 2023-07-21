# frozen_string_literal: true

require_relative '../../lib/mastodon/sidekiq_middleware'

Sidekiq.configure_server do |config|
  if Rails.configuration.database_configuration.dig('production', 'adapter') == 'postgresql_makara'
    STDERR.puts 'ERROR: Database replication is not currently supported in Sidekiq workers. Check your configuration.'
    exit 1
  end

  config.redis = REDIS_SIDEKIQ_PARAMS

  config.server_middleware do |chain|
    chain.add Mastodon::SidekiqMiddleware
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_SIDEKIQ_PARAMS

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end

Sidekiq.logger.level = ::Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)

SidekiqUniqueJobs.configure do |config|
  config.reaper          = :ruby
  config.reaper_count    = 1000
  config.reaper_interval = 600
  config.reaper_timeout  = 150
  config.lock_ttl        = 50.days.to_i
end

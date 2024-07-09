# frozen_string_literal: true

require_relative '../../lib/mastodon/sidekiq_middleware'

SIDEKIQ_WILL_PROCESSES_JOBS_FILE = Rails.root.join('tmp', 'sidekiq_process_has_started_and_will_begin_processing_jobs').freeze

Sidekiq.configure_server do |config|
  config.redis = REDIS_SIDEKIQ_PARAMS

  # This is used in Kubernetes setups, to signal that the Sidekiq process has started and will begin processing jobs
  # This comes from https://github.com/sidekiq/sidekiq/wiki/Kubernetes#sidekiq
  config.on(:startup) do
    FileUtils.touch(SIDEKIQ_WILL_PROCESSES_JOBS_FILE)
  end

  config.on(:shutdown) do
    FileUtils.rm_f(SIDEKIQ_WILL_PROCESSES_JOBS_FILE)
  end

  config.server_middleware do |chain|
    chain.add Mastodon::SidekiqMiddleware
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.on(:startup) do
    if SelfDestructHelper.self_destruct?
      Sidekiq.schedule = {
        'self_destruct_scheduler' => {
          'interval' => ['1m'],
          'class' => 'Scheduler::SelfDestructScheduler',
          'queue' => 'scheduler',
        },
      }
      SidekiqScheduler::Scheduler.instance.reload_schedule!
    end
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
  config.enabled         = !Rails.env.test?
  config.reaper          = :ruby
  config.reaper_count    = 1000
  config.reaper_interval = 600
  config.reaper_timeout  = 150
  config.lock_ttl        = 50.days.to_i
end

# frozen_string_literal: true

require_relative '../../lib/mastodon/sidekiq_middleware'
require_relative '../../lib/mastodon/worker_batch_middleware'

Sidekiq.configure_server do |config|
  config.redis = REDIS_CONFIGURATION.sidekiq

  # This is used in Kubernetes setups, to signal that the Sidekiq process has started and will begin processing jobs
  # This comes from https://github.com/sidekiq/sidekiq/wiki/Kubernetes#sidekiq
  ready_filename = ENV.fetch('MASTODON_SIDEKIQ_READY_FILENAME', nil)
  if ready_filename
    raise 'MASTODON_SIDEKIQ_READY_FILENAME is not a valid filename' if File.basename(ready_filename) != ready_filename

    ready_path = Rails.root.join('tmp', ready_filename)

    config.on(:startup) do
      FileUtils.touch(ready_path)
    end

    config.on(:shutdown) do
      FileUtils.rm_f(ready_path)
    end
  end

  if ENV['MASTODON_PROMETHEUS_EXPORTER_ENABLED'] == 'true'
    require 'prometheus_exporter'
    require 'prometheus_exporter/instrumentation'

    if ENV['MASTODON_PROMETHEUS_EXPORTER_LOCAL'] == 'true'
      config.on :startup do
        Mastodon::PrometheusExporter::LocalServer.setup!
      end
    end

    config.on :startup do
      # Ruby process metrics (memory, GC, etc)
      PrometheusExporter::Instrumentation::Process.start type: 'sidekiq'

      # Sidekiq process metrics (concurrency, busy, etc)
      PrometheusExporter::Instrumentation::SidekiqProcess.start

      # ActiveRecord metrics (connection pool usage)
      PrometheusExporter::Instrumentation::ActiveRecord.start(
        custom_labels: { type: 'sidekiq' },
        config_labels: [:database, :host]
      )

      if ENV['MASTODON_PROMETHEUS_EXPORTER_SIDEKIQ_DETAILED_METRICS'] == 'true'
        # Optional, as those metrics might generate extra overhead and be redundant with what OTEL provides

        # Per-job metrics
        config.server_middleware do |chain|
          chain.add PrometheusExporter::Instrumentation::Sidekiq
        end
        config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler

        # Per-queue metrics for queues handled by this process (size, latency, etc)
        # They will be reported by every process handling those queues, so do not sum them up
        PrometheusExporter::Instrumentation::SidekiqQueue.start

        # Global Sidekiq metrics (size of the global queues, number of jobs, etc)
        # Will be the same for every Sidekiq process
        PrometheusExporter::Instrumentation::SidekiqStats.start
      end
    end

    at_exit do
      # Wait for the latest metrics to be reported before shutting down
      PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
    end
  end

  config.server_middleware do |chain|
    chain.add Mastodon::SidekiqMiddleware
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
    chain.add Mastodon::WorkerBatchMiddleware
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

  config.logger.level = Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_CONFIGURATION.sidekiq

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
    chain.add Mastodon::WorkerBatchMiddleware
  end

  config.logger.level = Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)
end

SidekiqUniqueJobs.configure do |config|
  config.enabled         = !Rails.env.test?
  config.reaper          = :ruby
  config.reaper_count    = 1000
  config.reaper_interval = 600
  config.reaper_timeout  = 150
  config.lock_ttl        = 50.days.to_i
end

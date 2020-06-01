# frozen_string_literal: true

namespace    = ENV.fetch('REDIS_NAMESPACE') { nil }
redis_params = { url: ENV['REDIS_URL'] }

if namespace
  redis_params[:namespace] = namespace
end

Sidekiq.configure_server do |config|
  config.redis = redis_params

  config.server_middleware do |chain|
    require 'prometheus_exporter/instrumentation'
    chain.add SidekiqErrorHandler
    chain.add PrometheusExporter::Instrumentation::Sidekiq
  end

  config.death_handlers << lambda do |job, _ex|
    digest = job['lock_digest']
    SidekiqUniqueJobs::Digests.delete_by_digest(digest) if digest
    PrometheusExporter::Instrumentation::Sidekiq.death_handler
  end

  config.on :startup do
    require 'prometheus_exporter/instrumentation'
    PrometheusExporter::Instrumentation::Process.start type: 'sidekiq'
    PrometheusExporter::Instrumentation::ActiveRecord.start(
        custom_labels: { type: "sidekiq" }
    )
  end

  at_exit do
    PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_params
end

Sidekiq.logger.level = ::Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)

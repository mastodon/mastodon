# frozen_string_literal: true

namespace    = ENV.fetch('REDIS_NAMESPACE') { nil }
redis_params = { url: ENV['REDIS_URL'] }

if namespace
  redis_params[:namespace] = namespace
end

Sidekiq.configure_server do |config|
  require 'prometheus_exporter/instrumentation'
  require 'prometheus_exporter/client'
  
  prometheus_exporter_host = ENV.fetch('PROMETHEUS_EXPORTER_HOST') { 'prometheus_exporter' }
  prometheus_client = PrometheusExporter::Client.new(host: prometheus_exporter_host)
  PrometheusExporter::Client.default = prometheus_client

  config.redis = redis_params

  config.server_middleware do |chain|
    chain.add SidekiqErrorHandler
    chain.add PrometheusExporter::Instrumentation::Sidekiq
  end

  config.death_handlers << lambda do |job, _ex|
    digest = job['lock_digest']
    SidekiqUniqueJobs::Digests.delete_by_digest(digest) if digest
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_params
end

Sidekiq.logger.level = ::Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)

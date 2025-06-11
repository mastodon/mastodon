# frozen_string_literal: true

if ENV['MASTODON_PROMETHEUS_EXPORTER_ENABLED'] == 'true'
  require 'prometheus_exporter'
  require 'prometheus_exporter/middleware'

  require 'mastodon/prometheus_exporter/local_server' if ENV['MASTODON_PROMETHEUS_EXPORTER_LOCAL'] == 'true'

  if ENV['MASTODON_PROMETHEUS_EXPORTER_WEB_DETAILED_METRICS'] == 'true'
    # Optional, as those metrics might generate extra overhead and be redundant with what OTEL provides
    # Per-action/controller request stats like HTTP status and timings
    Rails.application.middleware.unshift PrometheusExporter::Middleware
  else
    # Include stripped down version of PrometheusExporter::Middleware that only collects queue time
    require 'mastodon/middleware/prometheus_queue_time'
    Rails.application.middleware.unshift Mastodon::Middleware::PrometheusQueueTime, instrument: false
  end
end

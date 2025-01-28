# frozen_string_literal: true

if ENV['MASTODON_PROMETHEUS_EXPORTER_ENABLED'] == 'true'
  if ENV['MASTODON_PROMETHEUS_EXPORTER_LOCAL'] == 'true'
    require 'prometheus_exporter/server'
    require 'prometheus_exporter/client'

    # bind is the address, on which the webserver will listen
    # port is the port that will provide the /metrics route
    server = PrometheusExporter::Server::WebServer.new bind: ENV.fetch('MASTODON_PROMETHEUS_EXPORTER_HOST', 'localhost'), port: ENV.fetch('MASTODON_PROMETHEUS_EXPORTER_PORT', '9394').to_i
    server.start

    # wire up a default local client
    PrometheusExporter::Client.default = PrometheusExporter::LocalClient.new(collector: server.collector)
  end

  if ENV['MASTODON_PROMETHEUS_EXPORTER_WEB_DETAILED_METRICS'] == 'true'
    # Optional, as those metrics might generate extra overhead and be redundant with what OTEL provides
    require 'prometheus_exporter/middleware'

    # Per-action/controller request stats like HTTP status and timings
    Rails.application.middleware.unshift PrometheusExporter::Middleware
  end
end

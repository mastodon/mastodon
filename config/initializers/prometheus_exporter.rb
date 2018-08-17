unless Rails.env == "test"
    require 'prometheus_exporter/middleware'
    require 'prometheus_exporter/client'
  
    prometheus_exporter_host = ENV.fetch('PROMETHEUS_EXPORTER_HOST') { 'prometheus_exporter' }
    prometheus_client = PrometheusExporter::Client.new(host: prometheus_exporter_host)
    PrometheusExporter::Client.default = prometheus_client

    # This reports stats per request like HTTP status and timings
    Rails.application.middleware.unshift PrometheusExporter::Middleware

end


# frozen_string_literal: true

persistent_timeout ENV.fetch('PERSISTENT_TIMEOUT') { 20 }.to_i

max_threads_count = ENV.fetch('MAX_THREADS') { 5 }.to_i
min_threads_count = ENV.fetch('MIN_THREADS') { max_threads_count }.to_i
threads min_threads_count, max_threads_count

if ENV['SOCKET']
  bind "unix://#{ENV['SOCKET']}"
else
  bind "tcp://#{ENV.fetch('BIND', '127.0.0.1')}:#{ENV.fetch('PORT', 3000)}"
end

workers ENV.fetch('WEB_CONCURRENCY') { 2 }.to_i

preload_app!

if ENV['MASTODON_PROMETHEUS_EXPORTER_ENABLED'] == 'true'
  require 'prometheus_exporter'
  require 'prometheus_exporter/instrumentation'

  if ENV['MASTODON_PROMETHEUS_EXPORTER_LOCAL'] == 'true'
    before_fork do
      Mastodon::PrometheusExporter::LocalServer.setup!
    end
  end

  before_worker_boot do
    # Ruby process metrics (memory, GC, etc)
    PrometheusExporter::Instrumentation::Process.start(type: 'puma')

    # ActiveRecord metrics (connection pool usage)
    PrometheusExporter::Instrumentation::ActiveRecord.start(
      custom_labels: { type: 'puma' }, # optional params
      config_labels: [:database, :host] # optional params
    )
  end

  after_worker_boot do
    # Puma metrics
    PrometheusExporter::Instrumentation::Puma.start unless PrometheusExporter::Instrumentation::Puma.started?
  end
end

plugin :tmp_restart

set_remote_address(proxy_protocol: :v1) if ENV['PROXY_PROTO_V1'] == 'true'

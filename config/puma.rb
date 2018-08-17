threads_count = ENV.fetch('MAX_THREADS') { 5 }.to_i
threads threads_count, threads_count

if ENV['SOCKET'] then
  bind 'unix://' + ENV['SOCKET']
else
  port ENV.fetch('PORT') { 3000 }
end

environment ENV.fetch('RAILS_ENV') { 'development' }
workers     ENV.fetch('WEB_CONCURRENCY') { 2 }

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)

  require 'prometheus_exporter/instrumentation'
  require 'prometheus_exporter/client'
  
  prometheus_exporter_host = ENV.fetch('PROMETHEUS_EXPORTER_HOST') { 'prometheus_exporter' }
  prometheus_client = PrometheusExporter::Client.new(host: prometheus_exporter_host)
  PrometheusExporter::Client.default = prometheus_client

  # this reports basic process stats like RSS and GC info
  PrometheusExporter::Instrumentation::Process.start(type: "master")
  PrometheusExporter::Instrumentation::Process.start(type:"web")

end

plugin :tmp_restart

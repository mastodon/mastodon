require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/action_pack'
require 'opentelemetry/instrumentation/action_view'
require 'opentelemetry/instrumentation/active_job'
require 'opentelemetry/instrumentation/active_model_serializers'
require 'opentelemetry/instrumentation/active_record'
require 'opentelemetry/instrumentation/active_support'
require 'opentelemetry/instrumentation/concurrent_ruby'
require 'opentelemetry/instrumentation/excon'
require 'opentelemetry/instrumentation/faraday'
require 'opentelemetry/instrumentation/http'
require 'opentelemetry/instrumentation/http_client'
require 'opentelemetry/instrumentation/net/http'
require 'opentelemetry/instrumentation/pg'
require 'opentelemetry/instrumentation/rack'
require 'opentelemetry/instrumentation/rails'
require 'opentelemetry/instrumentation/redis'
require 'opentelemetry/instrumentation/sidekiq'

OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::ActionPack'
  c.use 'OpenTelemetry::Instrumentation::ActionView'
  c.use 'OpenTelemetry::Instrumentation::ActiveJob'
  c.use 'OpenTelemetry::Instrumentation::ActiveModelSerializers'
  c.use 'OpenTelemetry::Instrumentation::ActiveRecord'
  c.use 'OpenTelemetry::Instrumentation::ActiveSupport'
  c.use 'OpenTelemetry::Instrumentation::CuncurrentRuby'
  c.use 'OpenTelemetry::Instrumentation::Excon'
  c.use 'OpenTelemetry::Instrumentation::Faraday'
  c.use 'OpenTelemetry::Instrumentation::HTTP'
  c.use 'OpenTelemetry::Instrumentation::HttpClient'
  c.use 'OpenTelemetry::Instrumentation::Net::HTTP'
  c.use 'OpenTelemetry::Instrumentation::PG'
  c.use 'OpenTelemetry::Instrumentation::Rack'
  c.use 'OpenTelemetry::Instrumentation::Rails'
  c.use 'OpenTelemetry::Instrumentation::Redis'
  c.use 'OpenTelemetry::Instrumentation::Sidekiq'

  c.service_name =  case $PROGRAM_NAME
                    when /puma/ then 'web'
                    when /sidekiq/ then 'sidekiq'
                    else
                      $PROGRAM_NAME.split('/').last
                    end
end

OpenTelemetry::Instrumentation::ActiveSupport.subscribe(
  OpenTelemetry.tracer_provider.tracer('ActiveRecord'),
  'sql.active_record'
)

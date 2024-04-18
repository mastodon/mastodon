# frozen_string_literal: true

if ENV.keys.any? { |name| name.match?(/OTEL_.*_ENDPOINT/) }

  require 'opentelemetry/sdk'
  require 'opentelemetry/exporter/otlp'
  require 'opentelemetry/instrumentation/action_pack'
  require 'opentelemetry/instrumentation/action_view'
  require 'opentelemetry/instrumentation/active_job'
  require 'opentelemetry/instrumentation/active_model_serializers'
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
    c.use_all

    c.service_name =  case $PROGRAM_NAME
                      when /puma/ then 'mastodon/web'
                      else
                        "mastodon/#{$PROGRAM_NAME.split('/').last}"
                      end
  end

  # Create spans for some ActiveRecord activity (queries, but not callbacks)
  # by subscribing OTel's ActiveSupport instrument to `sql.active_record` events
  # https://guides.rubyonrails.org/active_support_instrumentation.html#active-record
  OpenTelemetry::Instrumentation::ActiveSupport.subscribe(
    OpenTelemetry.tracer_provider.tracer('ActiveRecord'),
    'sql.active_record'
  )
end

# frozen_string_literal: true

# Set OTEL_* environment variables according to OTel docs:
# https://opentelemetry.io/docs/concepts/sdk-configuration/

if ENV.keys.any? { |name| name.match?(/OTEL_.*_ENDPOINT/) }
  require 'opentelemetry/sdk'
  require 'opentelemetry/exporter/otlp'

  require 'opentelemetry/instrumentation/active_job'
  require 'opentelemetry/instrumentation/active_model_serializers'
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
    # use_all() attempts to load ALL the auto-instrumentations
    # currently loaded by Ruby requires.
    #
    # Load attempts will emit an INFO or WARN to the console
    # about the success/failure to wire up an auto-instrumentation.
    # "WARN -- : Instrumentation: <X> failed to install" is most
    # likely caused by <X> not being a Ruby library loaded by
    # the application or the instrumentation has been explicitly
    # disabled.
    #
    # To disable an instrumentation, set an environment variable
    # along this pattern:
    #
    # OTEL_RUBY_INSTRUMENTATION_<X>_ENABLED=false
    #
    # For example, PostgreSQL and Redis produce a lot of child spans
    # in the course of this application doing its business. To turn
    # them off, set the env vars below, but recognize that you will
    # be missing details about what particular calls to the
    # datastores are slow.
    #
    # OTEL_RUBY_INSTRUMENTATION_PG_ENABLED=false
    # OTEL_RUBY_INSTRUMENTATION_REDIS_ENABLED=false

    c.use_all({
      'OpenTelemetry::Instrumentation::Rack' => {
        use_rack_events: false, # instead of events, use middleware; allows for untraced_endpoints to ignore child spans
        untraced_endpoints: ['/health'],
      },
      'OpenTelemetry::Instrumentation::Sidekiq' => {
        span_naming: :job_class, # Use the job class as the span name, otherwise this is the queue name and not very helpful
      },
      'OpenTelemetry::Instrumentation::Redis' => {
        trace_root_spans: false, # don't start traces with Redis spans
      },
    })

    prefix    = ENV.fetch('OTEL_SERVICE_NAME_PREFIX', 'mastodon')
    separator = ENV.fetch('OTEL_SERVICE_NAME_SEPARATOR', '/')

    c.service_name =  case $PROGRAM_NAME
                      when /puma/ then "#{prefix}#{separator}web"
                      else
                        "#{prefix}#{separator}#{$PROGRAM_NAME.split('/').last}"
                      end
    c.service_version = Mastodon::Version.to_s

    if Mastodon::Version.source_commit.present?
      c.resource = OpenTelemetry::SDK::Resources::Resource.create(
        'vcs.repository.ref.revision' => Mastodon::Version.source_commit,
        'vcs.repository.url.full' => Mastodon::Version.source_base_url
      )
    end
  end

  # This middleware adds the trace_id and span_id to the Rails logging tags for every requests
  class TelemetryLoggingMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      span = OpenTelemetry::Trace.current_span

      unless span.recording?
        @app.call(env)
        return
      end

      span_id = span.context.hex_span_id
      trace_id = span.context.hex_trace_id

      Rails.logger.tagged("trace_id=#{trace_id}", "span_id=#{span_id}") do
        @app.call(env)
      end
    end
  end

  Rails.application.configure do
    config.middleware.insert_before Rails::Rack::Logger, TelemetryLoggingMiddleware
  end

end

MastodonOTELTracer = OpenTelemetry.tracer_provider.tracer('mastodon')

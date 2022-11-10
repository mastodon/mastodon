# frozen_string_literal: true

# Set OTEL_* environment variables according to OTel docs:
# https://opentelemetry.io/docs/concepts/sdk-configuration/
#
# Totally hypothetically, if one wanted to send traces to Honeycomb,
# OTEL_EXPORTER_OTLP_ENDPOINT=https://api.honeycomb.io
# OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=<apikey>"

# If an OTEL endpoint of some variety has been set,
# light things up.
if ENV.keys.any? { |name| name.match?(/OTEL_.*_ENDPOINT/) }
  # required for the crafting of telemetry
  require 'opentelemetry/sdk'
  # required for the sending of telemetry
  require 'opentelemetry/exporter/otlp'
  # convenience to include all auto-instrumentations
  # available from OTel Ruby contrib
  require 'opentelemetry/instrumentation/all'

  OpenTelemetry::SDK.configure do |c|
    # You may optionally set the service.name for a process
    # with an environment variable the OTel SDK looks for.
    #
    # For example, when running rake tasks, you might set
    # this env var to 'rake' or be specific with 'db:migrate'.
    if ENV['OTEL_SERVICE_NAME'].blank?
      # If left unseet, the service.name in the telemetry
      # emitted from a process will match the name given for
      # a process/service in the runners (e.g. Procfile,
      # docker-compose, etc) to help a person running Mastodon
      # map behavior back to a service.
      c.service_name =  case $PROGRAM_NAME
                        when /puma/ then 'web'
                        when /sidekiq/ then 'sidekiq'
                        else
                          $PROGRAM_NAME.split('/').last
                        end
    end

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
    #
    # ActiveRecord instrumentation disabled while investigating interaction
    # with attr_encrypted and both gems patching of ActiveRecord#reload
    c.use_all({ 'OpenTelemetry::Instrumentation::ActiveRecord' => { enabled: false } })
  end

  # Create spans for some ActiveRecord activity (queries, but not callbacks)
  # by subscribing OTel's ActiveSupport instrument to `sql.active_record` events
  # https://guides.rubyonrails.org/active_support_instrumentation.html#active-record
  OpenTelemetry::Instrumentation::ActiveSupport.subscribe(
    OpenTelemetry.tracer_provider.tracer('ActiveRecord'),
    'sql.active_record'
  )
end

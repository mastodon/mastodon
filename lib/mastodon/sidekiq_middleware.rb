# frozen_string_literal: true

class Mastodon::SidekiqMiddleware
  BACKTRACE_LIMIT = 3

  def call(_worker_class, job, _queue, &block)
    setup_query_log_tags(job) do
      Chewy.strategy(:mastodon, &block)
    end
  rescue Mastodon::HostValidationError
    # Do not retry
  rescue => e
    clean_up_elasticsearch_connections!
    limit_backtrace_and_raise(e)
  ensure
    clean_up_sockets!
  end

  private

  def limit_backtrace_and_raise(exception)
    exception.set_backtrace(exception.backtrace.first(BACKTRACE_LIMIT)) unless ENV['BACKTRACE']
    raise exception
  end

  def clean_up_sockets!
    clean_up_redis_socket!
    clean_up_statsd_socket!
  end

  # This is a hack to immediately free up unused Elasticsearch connections.
  #
  # Indeed, Chewy creates one `Elasticsearch::Client` instance per thread,
  # and each such client manages its long-lasting connection to
  # Elasticsearch.
  #
  # As far as I know, neither `chewy`,  `elasticsearch-transport` or even
  # `faraday` provide a reliable way to immediately close a connection, and
  # rely on the underlying object to be garbage-collected instead.
  #
  # Furthermore, `sidekiq` creates a new thread each time a job throws an
  # exception, meaning that each failure will create a new connection, and
  # the old one will only be closed on full garbage collection.
  def clean_up_elasticsearch_connections!
    return unless Chewy.enabled? && Chewy.current[:chewy_client].present?

    Chewy.client.transport.transport.connections.each do |connection|
      # NOTE: This bit of code is tailored for the HTTPClient Faraday adapter
      connection.connection.app.instance_variable_get(:@client)&.reset_all
    end

    Chewy.current.delete(:chewy_client)
  rescue
    nil
  end

  def clean_up_redis_socket!
    RedisConnection.pool.checkin if Thread.current[:redis]
    Thread.current[:redis] = nil
  end

  def clean_up_statsd_socket!
    Thread.current[:statsd_socket]&.close
    Thread.current[:statsd_socket] = nil
  end

  def setup_query_log_tags(job, &block)
    if Rails.configuration.active_record.query_log_tags_enabled
      # If `wrapped` is set, this is an `ActiveJob` which is already in the execution context
      sidekiq_job_class = job['wrapped'].present? ? nil : job['class'].to_s
      ActiveSupport::ExecutionContext.set(sidekiq_job_class: sidekiq_job_class, &block)
    else
      yield
    end
  end
end

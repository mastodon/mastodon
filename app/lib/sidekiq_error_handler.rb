# frozen_string_literal: true

class SidekiqErrorHandler
  BACKTRACE_LIMIT = 3

  def call(*)
    yield
  rescue Mastodon::HostValidationError
    # Do not retry
  rescue => e
    limit_backtrace_and_raise(e)
  ensure
    socket = Thread.current[:statsd_socket]
    socket&.close
    Thread.current[:statsd_socket] = nil
  end

  private

  # rubocop:disable Naming/MethodParameterName
  def limit_backtrace_and_raise(e)
    e.set_backtrace(e.backtrace.first(BACKTRACE_LIMIT))
    raise e
  end
  # rubocop:enable Naming/MethodParameterName
end

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

  def limit_backtrace_and_raise(exception)
    exception.set_backtrace(exception.backtrace.first(BACKTRACE_LIMIT))
    raise exception
  end
end

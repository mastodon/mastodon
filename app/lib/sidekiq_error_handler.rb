# frozen_string_literal: true

class SidekiqErrorHandler
  def call(*)
    yield
  rescue Mastodon::HostValidationError
    # Do not retry
  ensure
    socket = Thread.current[:statsd_socket]
    socket&.close
    Thread.current[:statsd_socket] = nil
  end
end

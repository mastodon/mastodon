# frozen_string_literal: true

class Mastodon::SidekiqMiddleware
  BACKTRACE_LIMIT = 3

  def call(_, job, queue)
    # comment this out if mailers workers should not be skipped (i.e. we are sending emails)
    if queue == 'mailers'
      Sidekiq.logger.info("[skip_mailers] dropping #{job['class']} (jid=#{job['jid']})")
    else
      yield
    end
  rescue Mastodon::HostValidationError
    # Do not retry
  rescue => e
    limit_backtrace_and_raise(e)
  ensure
    clean_up_sockets!
  end

  private

  def limit_backtrace_and_raise(exception)
    exception.set_backtrace(exception.backtrace.first(BACKTRACE_LIMIT))
    raise exception
  end

  def clean_up_sockets!
    clean_up_redis_socket!
    clean_up_statsd_socket!
  end

  def clean_up_redis_socket!
    RedisConfiguration.pool.checkin if Thread.current[:redis]
    Thread.current[:redis] = nil
  end

  def clean_up_statsd_socket!
    Thread.current[:statsd_socket]&.close
    Thread.current[:statsd_socket] = nil
  end
end

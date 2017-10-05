# frozen_string_literal: true

module WorkerLogger
  def log_delay(published, url, at, current_time = Time.current)
    return unless published
    delay = current_time - Time.parse(published).utc
    logger.info format('source=%s destination=%s measure#delivery.delay=%.0fsec count#%s=1', self.class, url.inspect, delay, at)
  end
end

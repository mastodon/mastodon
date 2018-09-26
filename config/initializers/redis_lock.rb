# frozen_string_literal: true

require 'async'

class RedisLock
  def sleep(delay)
    Rails.logger.warn "Trying to sleep for #{delay}"
    if Async::Task.current?
      Async::Task.current.sleep delay
    else
      Kernel::sleep delay
    end
  end
end

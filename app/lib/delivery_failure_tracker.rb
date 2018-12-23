# frozen_string_literal: true

class DeliveryFailureTracker
  FAILURE_DAYS_THRESHOLD = 7

  def initialize(inbox_url)
    @inbox_url = inbox_url
  end

  def track_failure!
    Redis.current.sadd(exhausted_deliveries_key, today)
    Redis.current.sadd('unavailable_inboxes', @inbox_url) if reached_failure_threshold?
  end

  def track_success!
    Redis.current.del(exhausted_deliveries_key)
    Redis.current.srem('unavailable_inboxes', @inbox_url)
  end

  def days
    Redis.current.scard(exhausted_deliveries_key) || 0
  end

  class << self
    def filter(arr)
      arr.reject(&method(:unavailable?))
    end

    def unavailable?(url)
      Redis.current.sismember('unavailable_inboxes', url)
    end

    def available?(url)
      !unavailable?(url)
    end

    def track_inverse_success!(from_account)
      new(from_account.inbox_url).track_success! if from_account.inbox_url.present?
      new(from_account.shared_inbox_url).track_success! if from_account.shared_inbox_url.present?
    end
  end

  private

  def exhausted_deliveries_key
    "exhausted_deliveries:#{@inbox_url}"
  end

  def today
    Time.now.utc.strftime('%Y%m%d')
  end

  def reached_failure_threshold?
    days >= FAILURE_DAYS_THRESHOLD
  end
end

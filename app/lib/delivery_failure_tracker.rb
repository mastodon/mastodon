# frozen_string_literal: true

class DeliveryFailureTracker
  FAILURE_DAYS_THRESHOLD = 7

  def initialize(url_or_host)
    @host = url_or_host.start_with?('https://') || url_or_host.start_with?('http://') ? Addressable::URI.parse(url_or_host).normalized_host : url_or_host
  end

  def track_failure!
    Redis.current.sadd(exhausted_deliveries_key, today)
    UnavailableDomain.create(domain: @host) if reached_failure_threshold?
  end

  def track_success!
    Redis.current.del(exhausted_deliveries_key)
    UnavailableDomain.find_by(domain: @host)&.destroy
  end

  def days
    Redis.current.scard(exhausted_deliveries_key) || 0
  end

  def available?
    !UnavailableDomain.where(domain: @host).exists?
  end

  alias reset! track_success!

  class << self
    def without_unavailable(urls)
      unavailable_domains_map = Rails.cache.fetch('unavailable_domains') { UnavailableDomain.pluck(:domain).each_with_object({}) { |domain, hash| hash[domain] = true } }

      urls.reject do |url|
        host = Addressable::URI.parse(url).normalized_host
        unavailable_domains_map[host]
      end
    end

    def available?(url)
      new(url).available?
    end

    def reset!(url)
      new(url).reset!
    end
  end

  private

  def exhausted_deliveries_key
    "exhausted_deliveries:#{@host}"
  end

  def today
    Time.now.utc.strftime('%Y%m%d')
  end

  def reached_failure_threshold?
    days >= FAILURE_DAYS_THRESHOLD
  end
end

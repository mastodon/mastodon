# frozen_string_literal: true

class DeliveryFailureTracker
  include Redisable

  FAILURE_DAYS_THRESHOLD = 7

  def initialize(url_or_host)
    @host = url_or_host.start_with?('https://') || url_or_host.start_with?('http://') ? Addressable::URI.parse(url_or_host).normalized_host : url_or_host
  end

  def track_failure!
    redis.sadd(exhausted_deliveries_key, today)
    UnavailableDomain.create(domain: @host) if reached_failure_threshold?
  end

  def track_success!
    redis.del(exhausted_deliveries_key)
    UnavailableDomain.find_by(domain: @host)&.destroy
  end

  def clear_failures!
    redis.del(exhausted_deliveries_key)
  end

  def days
    redis.scard(exhausted_deliveries_key) || 0
  end

  def available?
    !UnavailableDomain.where(domain: @host).exists?
  end

  def exhausted_deliveries_days
    @exhausted_deliveries_days ||= redis.smembers(exhausted_deliveries_key).sort.map { |date| Date.new(date.slice(0, 4).to_i, date.slice(4, 2).to_i, date.slice(6, 2).to_i) }
  end

  alias reset! track_success!

  class << self
    include Redisable

    def without_unavailable(urls)
      unavailable_domains_map = Rails.cache.fetch('unavailable_domains') { UnavailableDomain.pluck(:domain).index_with(true) }

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

    def warning_domains
      domains = redis.keys(exhausted_deliveries_key_by('*')).map do |key|
        key.delete_prefix(exhausted_deliveries_key_by(''))
      end

      domains - UnavailableDomain.all.pluck(:domain)
    end

    def warning_domains_map(domains = nil)
      if domains.nil?
        warning_domains.index_with { |domain| redis.scard(exhausted_deliveries_key_by(domain)) }
      else
        domains -= UnavailableDomain.where(domain: domains).pluck(:domain)
        domains.index_with { |domain| redis.scard(exhausted_deliveries_key_by(domain)) }.filter { |_, days| days.positive? }
      end
    end

    private

    def exhausted_deliveries_key_by(host)
      "exhausted_deliveries:#{host}"
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

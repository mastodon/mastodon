# frozen_string_literal: true

module RateLimitHeaders
  extend ActiveSupport::Concern

  class_methods do
    def override_rate_limit_headers(method_name, options = {})
      around_action(only: method_name, if: :current_account) do |_controller, block|
        block.call
      ensure
        rate_limiter = RateLimiter.new(current_account, options)
        rate_limit_headers = rate_limiter.to_headers
        response.headers.merge!(rate_limit_headers) unless response.headers['X-RateLimit-Remaining'].present? && rate_limit_headers['X-RateLimit-Remaining'].to_i > response.headers['X-RateLimit-Remaining'].to_i
      end
    end
  end

  included do
    before_action :set_rate_limit_headers, if: :rate_limited_request?
  end

  private

  def set_rate_limit_headers
    apply_header_limit
    apply_header_remaining
    apply_header_reset
  end

  def rate_limited_request?
    !request.env['rack.attack.throttle_data'].nil?
  end

  def apply_header_limit
    response.headers['X-RateLimit-Limit'] = rate_limit_limit
  end

  def rate_limit_limit
    api_throttle_data[:limit].to_s
  end

  def apply_header_remaining
    response.headers['X-RateLimit-Remaining'] = rate_limit_remaining
  end

  def rate_limit_remaining
    (api_throttle_data[:limit] - api_throttle_data[:count]).to_s
  end

  def apply_header_reset
    response.headers['X-RateLimit-Reset'] = rate_limit_reset
  end

  def rate_limit_reset
    (request_time + reset_period_offset).iso8601(6)
  end

  def api_throttle_data
    most_limited_type, = request.env['rack.attack.throttle_data'].min_by { |_key, value| value[:limit] - value[:count] }
    request.env['rack.attack.throttle_data'][most_limited_type]
  end

  def request_time
    @_request_time ||= Time.now.utc
  end

  def reset_period_offset
    api_throttle_data[:period] - (request_time.to_i % api_throttle_data[:period])
  end
end

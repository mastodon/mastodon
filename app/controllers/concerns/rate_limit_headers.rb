# frozen_string_literal: true

module RateLimitHeaders
  extend ActiveSupport::Concern

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
    request.env['rack.attack.throttle_data']['api']
  end

  def request_time
    @_request_time ||= Time.now.utc
  end

  def reset_period_offset
    api_throttle_data[:period] - request_time.to_i % api_throttle_data[:period]
  end
end

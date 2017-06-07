# frozen_string_literal: true

module RateLimitHeaders
  extend ActiveSupport::Concern

  included do
    before_action :set_rate_limit_headers, if: :rate_limited_request?
  end

  private

  def set_rate_limit_headers
    response.headers['X-RateLimit-Limit']     = api_throttle_data[:limit].to_s
    response.headers['X-RateLimit-Remaining'] = (api_throttle_data[:limit] - api_throttle_data[:count]).to_s
    response.headers['X-RateLimit-Reset']     = (request_time + reset_period_offset).iso8601(6)
  end

  def rate_limited_request?
    !request.env['rack.attack.throttle_data'].nil?
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

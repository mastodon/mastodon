# frozen_string_literal: true

module RateLimitHeaders
  extend ActiveSupport::Concern

  included do
    before_action :set_rate_limit_headers, if: :rate_limited_request?
  end

  private

  def set_rate_limit_headers
    now        = Time.now.utc

    response.headers['X-RateLimit-Limit']     = api_throttle_data[:limit].to_s
    response.headers['X-RateLimit-Remaining'] = (api_throttle_data[:limit] - api_throttle_data[:count]).to_s
    response.headers['X-RateLimit-Reset']     = (now + (api_throttle_data[:period] - now.to_i % api_throttle_data[:period])).iso8601(6)
  end

  def rate_limited_request?
    !request.env['rack.attack.throttle_data'].nil?
  end

  def api_throttle_data
    request.env['rack.attack.throttle_data']['api']
  end
end

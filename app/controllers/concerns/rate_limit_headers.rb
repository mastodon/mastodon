# frozen_string_literal: true

module RateLimitHeaders
  extend ActiveSupport::Concern

  included do
    before_action :set_rate_limit_headers, if: :rate_limited_request?
  end

  private

  def set_rate_limit_headers
    now        = Time.now.utc
    match_data = request.env['rack.attack.throttle_data']['api']

    response.headers['X-RateLimit-Limit']     = match_data[:limit].to_s
    response.headers['X-RateLimit-Remaining'] = (match_data[:limit] - match_data[:count]).to_s
    response.headers['X-RateLimit-Reset']     = (now + (match_data[:period] - now.to_i % match_data[:period])).iso8601(6)
  end

  def rate_limited_request?
    !request.env['rack.attack.throttle_data'].nil?
  end
end

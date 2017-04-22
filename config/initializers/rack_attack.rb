# frozen_string_literal: true

class Rack::Attack
  # Rate limits for the API
  throttle('api', limit: 300, period: 5.minutes) do |req|
    req.ip if req.path =~ /\A\/api\/v/
  end

  # Rate limit logins
  throttle('login', limit: 5, period: 5.minutes) do |req|
    req.ip if req.path == '/auth/sign_in' && req.post?
  end

  # Rate limit sign-ups
  throttle('register', limit: 5, period: 5.minutes) do |req|
    req.ip if req.path == '/auth' && req.post?
  end

  # Rate limit forgotten passwords
  throttle('reminder', limit: 5, period: 5.minutes) do |req|
    req.ip if req.path == '/auth/password' && req.post?
  end

  self.throttled_response = lambda do |env|
    now        = Time.now.utc
    match_data = env['rack.attack.match_data']

    headers = {
      'X-RateLimit-Limit'     => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset'     => (now + (match_data[:period] - now.to_i % match_data[:period])).iso8601(6),
    }

    [429, headers, [{ error: 'Throttled' }.to_json]]
  end
end

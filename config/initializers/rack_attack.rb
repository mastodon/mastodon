# frozen_string_literal: true

require 'doorkeeper/grape/authorization_decorator'

class Rack::Attack
  class Request
    def authenticated_token
      return @token if defined?(@token)

      @token = Doorkeeper::OAuth::Token.authenticate(
        Doorkeeper::Grape::AuthorizationDecorator.new(self),
        *Doorkeeper.configuration.access_token_methods
      )
    end

    def authenticated_user_id
      authenticated_token&.resource_owner_id
    end

    def unauthenticated?
      !authenticated_user_id
    end

    def api_request?
      path.start_with?('/api')
    end

    def web_request?
      !api_request?
    end
  end

  PROTECTED_PATHS = %w(
    /auth/sign_in
    /auth
    /auth/password
  ).freeze

  PROTECTED_PATHS_REGEX = Regexp.union(PROTECTED_PATHS.map { |path| /\A#{Regexp.escape(path)}/ })

  # Always allow requests from localhost
  # (blocklist & throttles are skipped)
  Rack::Attack.safelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    req.ip == '127.0.0.1' || req.ip == '::1'
  end

  throttle('throttle_authenticated_api', limit: 300, period: 5.minutes) do |req|
    req.authenticated_user_id if req.api_request?
  end

  throttle('throttle_unauthenticated_api', limit: 7_500, period: 5.minutes) do |req|
    req.ip if req.api_request?
  end

  throttle('throttle_api_media', limit: 30, period: 30.minutes) do |req|
    req.authenticated_user_id if req.post? && req.path.start_with?('/api/v1/media')
  end

  throttle('throttle_api_sign_up', limit: 5, period: 30.minutes) do |req|
    req.ip if req.post? && req.path == '/api/v1/accounts'
  end

  API_DELETE_REBLOG_REGEX = /\A\/api\/v1\/statuses\/[\d]+\/unreblog/.freeze
  API_DELETE_STATUS_REGEX = /\A\/api\/v1\/statuses\/[\d]+/.freeze

  throttle('throttle_api_delete', limit: 30, period: 30.minutes) do |req|
    req.authenticated_user_id if (req.post? && req.path =~ API_DELETE_REBLOG_REGEX) || (req.delete? && req.path =~ API_DELETE_STATUS_REGEX)
  end

  throttle('protected_paths', limit: 25, period: 5.minutes) do |req|
    req.ip if req.post? && req.path =~ PROTECTED_PATHS_REGEX
  end

  self.throttled_response = lambda do |env|
    now        = Time.now.utc
    match_data = env['rack.attack.match_data']

    headers = {
      'Content-Type'          => 'application/json',
      'X-RateLimit-Limit'     => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset'     => (now + (match_data[:period] - now.to_i % match_data[:period])).iso8601(6),
    }

    [429, headers, [{ error: I18n.t('errors.429') }.to_json]]
  end
end

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

    def remote_ip
      @remote_ip ||= (@env["action_dispatch.remote_ip"] || ip).to_s
    end

    def throttleable_remote_ip
      @throttleable_remote_ip ||= begin
        ip = IPAddr.new(remote_ip)

        if ip.ipv6?
          ip.mask(64)
        else
          ip
        end
      end.to_s
    end

    def authenticated_user_id
      authenticated_token&.resource_owner_id
    end

    def authenticated_token_id
      authenticated_token&.id
    end

    def unauthenticated?
      !authenticated_user_id
    end

    def api_request?
      path.start_with?('/api')
    end

    def path_matches?(other_path)
      /\A#{Regexp.escape(other_path)}(\..*)?\z/ =~ path
    end

    def web_request?
      !api_request?
    end

    def paging_request?
      params['page'].present? || params['min_id'].present? || params['max_id'].present? || params['since_id'].present?
    end
  end

  Rack::Attack.safelist('allow from localhost') do |req|
    req.remote_ip == '127.0.0.1' || req.remote_ip == '::1'
  end

  Rack::Attack.blocklist('deny from blocklist') do |req|
    IpBlock.blocked?(req.remote_ip)
  end

  throttle('throttle_authenticated_api', limit: 1_500, period: 5.minutes) do |req|
    req.authenticated_user_id if req.api_request?
  end

  throttle('throttle_per_token_api', limit: 300, period: 5.minutes) do |req|
    req.authenticated_token_id if req.api_request?
  end

  throttle('throttle_unauthenticated_api', limit: 300, period: 5.minutes) do |req|
    req.throttleable_remote_ip if req.api_request? && req.unauthenticated?
  end

  throttle('throttle_api_media', limit: 30, period: 30.minutes) do |req|
    req.authenticated_user_id if req.post? && req.path.match?(/\A\/api\/v\d+\/media\z/i)
  end

  throttle('throttle_media_proxy', limit: 30, period: 10.minutes) do |req|
    req.throttleable_remote_ip if req.path.start_with?('/media_proxy')
  end

  throttle('throttle_api_sign_up', limit: 5, period: 30.minutes) do |req|
    req.throttleable_remote_ip if req.post? && req.path == '/api/v1/accounts'
  end

  throttle('throttle_authenticated_paging', limit: 300, period: 15.minutes) do |req|
    req.authenticated_user_id if req.paging_request?
  end

  throttle('throttle_unauthenticated_paging', limit: 300, period: 15.minutes) do |req|
    req.throttleable_remote_ip if req.paging_request? && req.unauthenticated?
  end

  API_DELETE_REBLOG_REGEX = /\A\/api\/v1\/statuses\/[\d]+\/unreblog\z/
  API_DELETE_STATUS_REGEX = /\A\/api\/v1\/statuses\/[\d]+\z/

  throttle('throttle_api_delete', limit: 30, period: 30.minutes) do |req|
    req.authenticated_user_id if (req.post? && req.path.match?(API_DELETE_REBLOG_REGEX)) || (req.delete? && req.path.match?(API_DELETE_STATUS_REGEX))
  end

  throttle('throttle_sign_up_attempts/ip', limit: 25, period: 5.minutes) do |req|
    req.throttleable_remote_ip if req.post? && req.path_matches?('/auth')
  end

  throttle('throttle_password_resets/ip', limit: 25, period: 5.minutes) do |req|
    req.throttleable_remote_ip if req.post? && req.path_matches?('/auth/password')
  end

  throttle('throttle_password_resets/email', limit: 5, period: 30.minutes) do |req|
    req.params.dig('user', 'email').presence if req.post? && req.path_matches?('/auth/password')
  end

  throttle('throttle_email_confirmations/ip', limit: 25, period: 5.minutes) do |req|
    req.throttleable_remote_ip if req.post? && (req.path_matches?('/auth/confirmation') || req.path == '/api/v1/emails/confirmations')
  end

  throttle('throttle_email_confirmations/email', limit: 5, period: 30.minutes) do |req|
    if req.post? && req.path_matches?('/auth/password')
      req.params.dig('user', 'email').presence
    elsif req.post? && req.path == '/api/v1/emails/confirmations'
      req.authenticated_user_id
    end
  end

  throttle('throttle_login_attempts/ip', limit: 25, period: 5.minutes) do |req|
    req.throttleable_remote_ip if req.post? && req.path_matches?('/auth/sign_in')
  end

  throttle('throttle_login_attempts/email', limit: 25, period: 1.hour) do |req|
    req.session[:attempt_user_id] || req.params.dig('user', 'email').presence if req.post? && req.path_matches?('/auth/sign_in')
  end

  self.throttled_responder = lambda do |request|
    now        = Time.now.utc
    match_data = request.env['rack.attack.match_data']

    headers = {
      'Content-Type'          => 'application/json',
      'X-RateLimit-Limit'     => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset'     => (now + (match_data[:period] - (now.to_i % match_data[:period]))).iso8601(6),
    }

    [429, headers, [{ error: I18n.t('errors.429') }.to_json]]
  end
end

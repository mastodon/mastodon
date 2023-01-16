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

  rate_limits = {
    authenticated_api: {
      count: ENV.fetch('AUTHENTICATED_API_RATE_LIMIT', 300),
      minutes: ENV.fetch('AUTHENTICATED_API_RATE_LIMIT_MINUTES', 5).minutes
    },
    unauthenticated_api: {
      count: ENV.fetch('UNAUTHENTICATED_API_RATE_LIMIT', 300),
      minutes: ENV.fetch('UNAUTHENTICATED_API_RATE_LIMIT_MINUTES', 5).minutes,
    },
    api_media: {
      count: ENV.fetch('API_MEDIA_RATE_LIMIT', 30),
      minutes: ENV.fetch('API_MEDIA_RATE_LIMIT_MINUTES', 30).minutes,
    },
    media_proxy: {
      count: ENV.fetch('MEDIA_PROXY_RATE_LIMIT', 30),
      minutes: ENV.fetch('MEDIA_PROXY_RATE_LIMIT_MINUTES', 10).minutes,
    },
    api_sign_up: {
      count: ENV.fetch('API_SIGN_UP_RATE_LIMIT', 5),
      minutes: ENV.fetch('API_SIGN_UP_RATE_LIMIT_MINUTES', 30).minutes,
    },
    authenticated_paging: {
      count: ENV.fetch('AUTHENTICATED_PAGING_RATE_LIMIT', 300),
      minutes: ENV.fetch('AUTHENTICATED_PAGING_RATE_LIMIT_MINUTES', 15).minutes,
    },
    unauthenticated_paging: {
      count: ENV.fetch('UNAUTHENTICATED_PAGING_RATE_LIMIT', 300),
      minutes: ENV.fetch('UNAUTHENTICATED_PAGING_RATE_LIMIT_MINUTES', 15).minutes,
    },
    api_delete: {
      count: ENV.fetch('API_DELETE_RATE_LIMIT', 30),
      minutes: ENV.fetch('API_DELETE_RATE_LIMIT_MINUTES', 30).minutes,
    },
    sign_up_attempts_ip: {
      count: ENV.fetch('SIGN_UP_ATTEMPTS_IP_RATE_LIMIT', 25),
      minutes: ENV.fetch('SIGN_UP_ATTEMPTS_IP_RATE_LIMIT_MINUTES', 5).minutes,
    },
    password_resets_ip: {
      count: ENV.fetch('PASSWORD_RESETS_IP_RATE_LIMIT', 25),
      minutes: ENV.fetch('PASSWORD_RESETS_IP_RATE_LIMIT_MINUTES', 5).minutes,
    },
    password_resets_email: {
      count: ENV.fetch('PASSWORD_RESETS_EMAIL_RATE_LIMIT', 5),
      minutes: ENV.fetch('PASSWORD_RESETS_EMAIL_RATE_LIMIT_MINUTES', 30).minutes,
    },
    email_confirmations_ip: {
      count: ENV.fetch('EMAIL_CONFIRMATIONS_IP_RATE_LIMIT', 25),
      minutes: ENV.fetch('EMAIL_CONFIRMATIONS_IP_RATE_LIMIT_MINUTES', 5).minutes,
    },
    email_confirmations_email: {
      count: ENV.fetch('EMAIL_CONFIRMATIONS_EMAIL_RATE_LIMIT', 5),
      minutes: ENV.fetch('EMAIL_CONFIRMATIONS_EMAIL_RATE_LIMIT_MINUTES', 30).minutes,
    },
    login_attempts_ip: {
      count: ENV.fetch('LOGIN_ATTEMPTS_IP_RATE_LIMIT', 25),
      minutes: ENV.fetch('LOGIN_ATTEMPTS_IP_RATE_LIMIT_MINUTES', 5).minutes,
    },
    login_attempts_email: {
      count: ENV.fetch('LOGIN_ATTEMPTS_EMAIL_RATE_LIMIT', 25),
      minutes: ENV.fetch('LOGIN_ATTEMPTS_EMAIL_RATE_LIMIT_MINUTES', 60).minutes,
    },
  }

  throttle(
    'throttle_authenticated_api',
    limit: rate_limits[:authenticated_api][:count],
    period: rate_limits[:authenticated_api][:minutes],
  ) do |req|
    req.authenticated_user_id if req.api_request?
  end

  throttle(
    'throttle_unauthenticated_api',
    limit: rate_limits[:unauthenticated_api][:count],
    period: rate_limits[:unauthenticated_api][:minutes],
  ) do |req|
    req.throttleable_remote_ip if req.api_request? && req.unauthenticated?
  end

  throttle(
    'throttle_api_media',
    limit: rate_limits[:api_media][:count],
    period: rate_limits[:api_media][:minutes],
  ) do |req|
    req.authenticated_user_id if req.post? && req.path.match?(/\A\/api\/v\d+\/media\z/i)
  end

  throttle(
    'throttle_media_proxy',
    limit: rate_limits[:media_proxy][:count],
    period: rate_limits[:media_proxy][:minutes],
  ) do |req|
    req.throttleable_remote_ip if req.path.start_with?('/media_proxy')
  end

  throttle(
    'throttle_api_sign_up',
    limit: rate_limits[:api_sign_up][:count],
    period: rate_limits[:api_sign_up][:minutes],
  ) do |req|
    req.throttleable_remote_ip if req.post? && req.path == '/api/v1/accounts'
  end

  throttle(
    'throttle_authenticated_paging',
    limit: rate_limits[:authenticated_paging][:count],
    period: rate_limits[:authenticated_paging][:minutes],
  ) do |req|
    req.authenticated_user_id if req.paging_request?
  end

  throttle(
    'throttle_unauthenticated_paging',
    limit: rate_limits[:unauthenticated_paging][:count],
    period: rate_limits[:unauthenticated_paging][:minutes],
  ) do |req|
    req.throttleable_remote_ip if req.paging_request? && req.unauthenticated?
  end

  API_DELETE_REBLOG_REGEX = /\A\/api\/v1\/statuses\/[\d]+\/unreblog\z/.freeze
  API_DELETE_STATUS_REGEX = /\A\/api\/v1\/statuses\/[\d]+\z/.freeze

  throttle(
    'throttle_api_delete',
    limit: rate_limits[:api_delete][:count],
    period: rate_limits[:api_delete][:minutes],
  ) do |req|
    req.authenticated_user_id if (req.post? && req.path.match?(API_DELETE_REBLOG_REGEX)) || (req.delete? && req.path.match?(API_DELETE_STATUS_REGEX))
  end

  throttle(
    'throttle_sign_up_attempts/ip',
    limit: rate_limits[:sign_up_attempts_ip][:count],
    period: rate_limits[:sign_up_attempts_ip][:minutes],
  ) do |req|
    req.throttleable_remote_ip if req.post? && req.path_matches?('/auth')
  end

  throttle(
    'throttle_password_resets/ip',
    limit: rate_limits[:password_resets_ip][:count],
    period: rate_limits[:password_resets_ip][:minutes],
  ) do |req|
    req.throttleable_remote_ip if req.post? && req.path_matches?('/auth/password')
  end

  throttle(
    'throttle_password_resets/email',
    limit: rate_limits[:password_resets_email][:count],
    period: rate_limits[:password_resets_email][:minutes],
  ) do |req|
    req.params.dig('user', 'email').presence if req.post? && req.path_matches?('/auth/password')
  end

  throttle(
    'throttle_email_confirmations/ip',
    limit: rate_limits[:email_confirmations_ip][:count],
    period: rate_limits[:email_confirmations_ip][:minutes],
  ) do |req|
    req.throttleable_remote_ip if req.post? && (req.path_matches?('/auth/confirmation') || req.path == '/api/v1/emails/confirmations')
  end

  throttle(
    'throttle_email_confirmations/email',
    limit: rate_limits[:email_confirmations_email][:count],
    period: rate_limits[:email_confirmations_email][:minutes],
  ) do |req|
    if req.post? && req.path_matches?('/auth/password')
      req.params.dig('user', 'email').presence
    elsif req.post? && req.path == '/api/v1/emails/confirmations'
      req.authenticated_user_id
    end
  end

  throttle(
    'throttle_login_attempts/ip',
    limit: rate_limits[:login_attempts_ip][:count],
    period: rate_limits[:login_attempts_ip][:minutes],
  ) do |req|
    req.throttleable_remote_ip if req.post? && req.path_matches?('/auth/sign_in')
  end

  throttle(
    'throttle_login_attempts/email',
    limit: rate_limits[:login_attempts_email][:count],
    period: rate_limits[:login_attempts_email][:minutes],
  ) do |req|
    req.session[:attempt_user_id] || req.params.dig('user', 'email').presence if req.post? && req.path_matches?('/auth/sign_in')
  end

  self.throttled_responder = lambda do |request|
    now        = Time.now.utc
    match_data = request.env['rack.attack.match_data']

    headers = {
      'Content-Type'          => 'application/json',
      'X-RateLimit-Limit'     => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset'     => (now + (match_data[:period] - now.to_i % match_data[:period])).iso8601(6),
    }

    [429, headers, [{ error: I18n.t('errors.429') }.to_json]]
  end
end

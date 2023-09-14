# frozen_string_literal: true

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

def host_to_url(str)
  "http#{Rails.configuration.x.use_https ? 's' : ''}://#{str.split('/').first}" if str.present?
end

base_host = Rails.configuration.x.web_domain

assets_host   = Rails.configuration.action_controller.asset_host
assets_host ||= host_to_url(base_host)

media_host   = host_to_url(ENV['S3_ALIAS_HOST'])
media_host ||= host_to_url(ENV['S3_CLOUDFRONT_HOST'])
media_host ||= host_to_url(ENV['AZURE_ALIAS_HOST'])
media_host ||= host_to_url(ENV['S3_HOSTNAME']) if ENV['S3_ENABLED'] == 'true'
media_host ||= assets_host

def sso_host
  return unless ENV['ONE_CLICK_SSO_LOGIN'] == 'true'
  return unless ENV['OMNIAUTH_ONLY'] == 'true'
  return unless Devise.omniauth_providers.length == 1

  provider = Devise.omniauth_configs[Devise.omniauth_providers[0]]
  @sso_host ||= begin
    case provider.provider
    when :cas
      provider.cas_url
    when :saml
      provider.options[:idp_sso_target_url]
    when :openid_connect
      provider.options.dig(:client_options, :authorization_endpoint) || OpenIDConnect::Discovery::Provider::Config.discover!(provider.options[:issuer]).authorization_endpoint
    end
  end
end

Rails.application.config.content_security_policy do |p|
  p.base_uri        :none
  p.default_src     :none
  p.frame_ancestors :none
  p.font_src        :self, assets_host
  p.img_src         :self, :https, :data, :blob, assets_host
  p.style_src       :self, assets_host
  p.media_src       :self, :https, :data, assets_host
  p.frame_src       :self, :https
  p.manifest_src    :self, assets_host

  if sso_host.present?
    p.form_action     :self, sso_host
  else
    p.form_action     :self
  end

  p.child_src       :self, :blob, assets_host
  p.worker_src      :self, :blob, assets_host

  if Rails.env.development?
    webpacker_public_host = ENV.fetch('WEBPACKER_DEV_SERVER_PUBLIC', Webpacker.config.dev_server[:public])
    webpacker_urls = %w(ws http).map { |protocol| "#{protocol}#{Webpacker.dev_server.https? ? 's' : ''}://#{webpacker_public_host}" }

    p.connect_src :self, :data, :blob, assets_host, media_host, Rails.configuration.x.streaming_api_base_url, *webpacker_urls
    p.script_src  :self, :unsafe_inline, :unsafe_eval, assets_host
  else
    p.connect_src :self, :data, :blob, assets_host, media_host, Rails.configuration.x.streaming_api_base_url
    p.script_src  :self, assets_host, "'wasm-unsafe-eval'"
  end
end

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true

Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

Rails.application.config.content_security_policy_nonce_directives = %w(style-src)

Rails.application.reloader.to_prepare do
  PgHero::HomeController.content_security_policy do |p|
    p.script_src :self, :unsafe_inline, assets_host
    p.style_src  :self, :unsafe_inline, assets_host
  end

  PgHero::HomeController.after_action do
    request.content_security_policy_nonce_generator = nil
  end

  if Rails.env.development?
    LetterOpenerWeb::LettersController.content_security_policy do |p|
      p.child_src       :self
      p.connect_src     :none
      p.frame_ancestors :self
      p.frame_src       :self
      p.script_src      :unsafe_inline
      p.style_src       :unsafe_inline
      p.worker_src      :none
    end

    LetterOpenerWeb::LettersController.after_action do |p|
      request.content_security_policy_nonce_directives = %w(script-src)
    end
  end
end

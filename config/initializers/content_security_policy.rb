# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

require_relative '../../app/lib/content_security_policy'

policy = ContentSecurityPolicy.new
assets_host = policy.assets_host
media_hosts = policy.media_hosts

Rails.application.config.content_security_policy do |p|
  p.base_uri        :none
  p.default_src     :none
  p.frame_ancestors :none
  p.font_src        :self, assets_host
  p.img_src         :self, :data, :blob, *media_hosts
  p.style_src       :self, assets_host
  p.media_src       :self, :data, *media_hosts
  p.manifest_src    :self, assets_host

  if policy.sso_host.present?
    p.form_action :self, policy.sso_host
  else
    p.form_action :self
  end

  p.child_src  :self, :blob, assets_host
  p.worker_src :self, :blob, assets_host

  if Rails.env.development?
    webpacker_public_host = ENV.fetch('WEBPACKER_DEV_SERVER_PUBLIC', Webpacker.config.dev_server[:public])
    front_end_build_urls = %w(ws http).map { |protocol| "#{protocol}#{Webpacker.dev_server.https? ? 's' : ''}://#{webpacker_public_host}" }

    p.connect_src :self, :data, :blob, *media_hosts, Rails.configuration.x.streaming_api_base_url, *front_end_build_urls
    p.script_src  :self, :unsafe_inline, :unsafe_eval, assets_host
    p.frame_src   :self, :https, :http
  else
    p.connect_src :self, :data, :blob, *media_hosts, Rails.configuration.x.streaming_api_base_url
    p.script_src  :self, assets_host, "'wasm-unsafe-eval'"
    p.frame_src   :self, :https
  end
end

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true

Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

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

    LetterOpenerWeb::LettersController.after_action do
      request.content_security_policy_nonce_directives = %w(script-src)
    end
  end
end

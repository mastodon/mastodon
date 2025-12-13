# frozen_string_literal: true

class ContentSecurityPolicy
  def base_host
    Rails.configuration.x.web_domain
  end

  def assets_host
    url_from_configured_asset_host || url_from_base_host
  end

  def media_hosts
    [assets_host, cdn_host_value, paperclip_root_url].concat(extra_media_hosts).compact
  end

  def sso_host
    return unless ENV['ONE_CLICK_SSO_LOGIN'] == 'true' && ENV['OMNIAUTH_ONLY'] == 'true' && Devise.omniauth_providers.length == 1

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

  private

  def extra_media_hosts
    ENV.fetch('EXTRA_MEDIA_HOSTS', '').split(/(?:\s*,\s*|\s+)/)
  end

  def url_from_configured_asset_host
    Rails.configuration.action_controller.asset_host
  end

  def cdn_host_value
    s3_alias_host || s3_cloudfront_host || azure_alias_host || s3_hostname_host || swift_object_url
  end

  def paperclip_root_url
    root_url = ENV.fetch('PAPERCLIP_ROOT_URL', nil)
    return if root_url.blank?

    (Addressable::URI.parse(assets_host) + root_url).tap do |uri|
      uri.path += '/' unless uri.path.blank? || uri.path.end_with?('/')
    end.to_s
  end

  def url_from_base_host
    host_to_url(base_host)
  end

  def host_to_url(host_string)
    uri_from_configuration_and_string(host_string) if host_string.present?
  end

  def s3_alias_host
    host_to_url ENV.fetch('S3_ALIAS_HOST', nil)
  end

  def s3_cloudfront_host
    host_to_url ENV.fetch('S3_CLOUDFRONT_HOST', nil)
  end

  def azure_alias_host
    host_to_url ENV.fetch('AZURE_ALIAS_HOST', nil)
  end

  def s3_hostname_host
    host_to_url ENV.fetch('S3_HOSTNAME', nil)
  end

  def swift_object_url
    url = ENV.fetch('SWIFT_OBJECT_URL', nil)
    return if url.blank? || !url.start_with?('https://')

    url += '/' unless url.end_with?('/')
    url
  end

  def uri_from_configuration_and_string(host_string)
    Addressable::URI.parse("#{host_protocol}://#{host_string}").tap do |uri|
      uri.path += '/' unless uri.path.blank? || uri.path.end_with?('/')
    end.to_s
  end

  def host_protocol
    Rails.configuration.x.use_https ? 'https' : 'http'
  end
end

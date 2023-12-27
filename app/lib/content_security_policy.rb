# frozen_string_literal: true

class ContentSecurityPolicy
  def base_host
    Rails.configuration.x.web_domain
  end

  def assets_host
    url_from_configured_asset_host || url_from_base_host
  end

  def media_hosts
    [assets_host, cdn_host_value].concat(extra_data_hosts).compact
  end

  private

  def extra_data_hosts
    ENV.fetch('EXTRA_DATA_HOSTS', '').split('|')
  end

  def url_from_configured_asset_host
    Rails.configuration.action_controller.asset_host
  end

  def cdn_host_value
    s3_alias_host || s3_cloudfront_host || azure_alias_host || s3_hostname_host
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

  def uri_from_configuration_and_string(host_string)
    Addressable::URI.parse("#{host_protocol}://#{host_string}").tap do |uri|
      uri.path += '/' unless uri.path.blank? || uri.path.end_with?('/')
    end.to_s
  end

  def host_protocol
    Rails.configuration.x.use_https ? 'https' : 'http'
  end
end

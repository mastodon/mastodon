# frozen_string_literal: true

class ContentSecurityPolicy
  def base_host
    Rails.configuration.x.web_domain
  end

  def assets_host
    url_from_configured_asset_host || url_from_base_host
  end

  private

  def url_from_configured_asset_host
    Rails.configuration.action_controller.asset_host
  end

  def url_from_base_host
    host_to_url(base_host)
  end

  def host_to_url(str)
    "http#{Rails.configuration.x.use_https ? 's' : ''}://#{str.split('/').first}" if str.present?
  end
end

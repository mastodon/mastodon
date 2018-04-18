# frozen_string_literal: true

module InstanceHelper
  def site_title
    Setting.site_title
  end

  def site_hostname
    @site_hostname ||= Addressable::URI.parse("//#{Rails.configuration.x.local_domain}").display_uri.host
  end
end

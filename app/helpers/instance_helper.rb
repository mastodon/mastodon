# frozen_string_literal: true

module InstanceHelper
  def site_title
    Setting.site_title
  end

  def site_hostname
    Setting.site_hostname_or_domain
  end
end

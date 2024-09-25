# frozen_string_literal: true

module Admin::Settings::DiscoveryHelper
  def discovery_warning_hint_text
    authorized_fetch_overridden? ? t('admin.settings.security.authorized_fetch_overridden_hint') : nil
  end

  def discovery_hint_text
    t('admin.settings.security.authorized_fetch_hint')
  end

  def discovery_recommended_value
    authorized_fetch_overridden? ? :overridden : nil
  end
end

# frozen_string_literal: true

class Admin::Settings::DiscoveryController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_discovery_path
  end
end

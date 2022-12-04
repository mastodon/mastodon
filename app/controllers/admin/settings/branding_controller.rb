# frozen_string_literal: true

class Admin::Settings::BrandingController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_branding_path
  end
end

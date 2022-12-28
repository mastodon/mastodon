# frozen_string_literal: true

class Admin::Settings::HometownController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_hometown_path
  end
end

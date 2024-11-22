# frozen_string_literal: true

class Admin::Settings::AppearanceController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_appearance_path
  end
end

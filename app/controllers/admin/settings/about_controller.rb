# frozen_string_literal: true

class Admin::Settings::AboutController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_about_path
  end
end

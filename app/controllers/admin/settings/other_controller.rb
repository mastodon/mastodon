# frozen_string_literal: true

class Admin::Settings::OtherController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_other_path
  end
end

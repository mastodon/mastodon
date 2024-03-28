# frozen_string_literal: true

class Admin::Settings::OthersController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_others_path
  end
end

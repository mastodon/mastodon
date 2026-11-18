# frozen_string_literal: true

class Admin::Settings::ExternalController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_external_path
  end
end

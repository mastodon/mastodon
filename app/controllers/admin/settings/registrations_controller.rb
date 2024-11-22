# frozen_string_literal: true

class Admin::Settings::RegistrationsController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_registrations_path
  end
end

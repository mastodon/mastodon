# frozen_string_literal: true

class Admin::Settings::ProtectionsController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_protections_path
  end
end

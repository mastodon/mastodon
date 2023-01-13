# frozen_string_literal: true

class Admin::Settings::ContentRetentionController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_content_retention_path
  end
end

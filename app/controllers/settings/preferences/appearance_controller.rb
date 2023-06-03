# frozen_string_literal: true

class Settings::Preferences::AppearanceController < Settings::Preferences::BaseController
  private

  def after_update_redirect_path
    settings_preferences_appearance_path
  end
end

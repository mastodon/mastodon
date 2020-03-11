# frozen_string_literal: true

class Settings::Preferences::OtherController < Settings::PreferencesController
  private

  def after_update_redirect_path
    settings_preferences_other_path
  end
end

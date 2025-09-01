# frozen_string_literal: true

class Settings::Preferences::PostingDefaultsController < Settings::Preferences::BaseController
  private

  def after_update_redirect_path
    settings_preferences_posting_defaults_path
  end
end

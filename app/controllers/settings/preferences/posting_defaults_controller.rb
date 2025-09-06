# frozen_string_literal: true

class Settings::Preferences::PostingDefaultsController < Settings::Preferences::BaseController
  private

  def after_update_redirect_path
    settings_preferences_posting_defaults_path
  end

  def user_params
    super.tap do |params|
      params[:settings_attributes][:default_quote_policy] = 'nobody' if params[:settings_attributes][:default_privacy] == 'private'
    end
  end
end

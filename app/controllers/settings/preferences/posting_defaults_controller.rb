# frozen_string_literal: true

class Settings::Preferences::PostingDefaultsController < Settings::Preferences::BaseController
  private

  def split_default_privacy
    case current_user.setting_default_privacy
    when 'public', 'unlisted'
      'public'
    else
      'private'
    end
  end
  helper_method :split_default_privacy

  def split_default_privacy_discoverable?
    current_user.setting_default_privacy == 'public'
  end
  helper_method :split_default_privacy_discoverable?

  def after_update_redirect_path
    settings_preferences_posting_defaults_path
  end

  def user_params
    params.expect(user: [:locale, :time_zone, chosen_languages: [], settings_attributes: UserSettings.keys + %w(split_default_privacy split_default_privacy_discoverable)]).tap do |params|
      if params[:settings_attributes][:split_default_privacy]
        default_privacy = params[:settings_attributes].delete(:split_default_privacy)
        discoverable = params[:settings_attributes].delete(:split_default_privacy_discoverable)
        default_privacy = 'unlisted' if default_privacy == 'public' && !ActiveModel::Type::Boolean.new.cast(discoverable)

        params[:settings_attributes][:default_privacy] = default_privacy
      end

      params[:settings_attributes][:default_quote_policy] = 'nobody' if params[:settings_attributes][:default_privacy] == 'private'
    end
  end
end

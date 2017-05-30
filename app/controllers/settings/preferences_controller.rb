# frozen_string_literal: true

class Settings::PreferencesController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show; end

  def update
    user_settings.update(user_settings_params.to_h)

    if current_user.update(user_params)
      I18n.locale = current_user.locale
      redirect_to settings_preferences_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :show
    end
  end

  private

  def user_settings
    UserSettingsDecorator.new(current_user)
  end

  def user_params
    params.require(:user).permit(
      :locale,
      filtered_languages: []
    )
  end

  def user_settings_params
    params.require(:user).permit(
      :setting_default_privacy,
      :setting_boost_modal,
      :setting_delete_modal,
      :setting_auto_play_gif,
      notification_emails: %i(follow follow_request reblog favourite mention digest),
      interactions: %i(must_be_follower must_be_following)
    )
  end
end

# frozen_string_literal: true

class Settings::PreferencesController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show; end

  def update
    if params[:user].nil?
      render :show
      return
    end

    user_settings_params = params[:user].permit(
      :setting_default_privacy,
      :setting_boost_modal,
      :setting_auto_play_gif,
      notification_emails: %i(follow follow_request reblog favourite mention digest),
      interactions: %i(must_be_follower must_be_following)
    )

    user_settings.update(user_settings_params.to_h)

    user_params = params[:user].permit(
      :locale,
      filtered_languages: []
    )

    unless current_user.update(user_params)
      render :show
      return
    end

    redirect_to settings_preferences_path, notice: I18n.t('generic.changes_saved_msg')
  end

  private

  def user_settings
    UserSettingsDecorator.new(current_user)
  end
end

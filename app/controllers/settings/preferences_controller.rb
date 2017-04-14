# frozen_string_literal: true

class Settings::PreferencesController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show; end

  def update
    update_user_settings

    if current_user.update(user_params)
      redirect_to settings_preferences_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :show
    end
  end

  private

  def update_user_settings
    current_user.settings['notification_emails'] = merged_notification_emails
    current_user.settings['interactions'] = merged_interactions
    current_user.settings['default_privacy'] = user_settings_params[:setting_default_privacy]
    current_user.settings['boost_modal'] = boost_modal_preference
    current_user.settings['auto_play_gif'] = auto_play_gif_preference
  end

  def merged_notification_emails
    current_user.settings['notification_emails'].merge user_notification_emails.to_h
  end

  def user_notification_emails
    coerce_values user_settings_params.fetch(:notification_emails, {})
  end

  def merged_interactions
    current_user.settings['interactions'].merge user_interactions.to_h
  end

  def user_interactions
    coerce_values user_settings_params.fetch(:interactions, {})
  end

  def boost_modal_preference
    user_settings_params[:setting_boost_modal] == '1'
  end

  def auto_play_gif_preference
    user_settings_params[:setting_auto_play_gif] == '1'
  end

  def coerce_values(params_hash)
    params_hash.transform_values { |x| x == '1' }
  end

  def user_params
    params.require(:user).permit(
      :locale
    )
  end

  def user_settings_params
    params.require(:user).permit(
      :setting_default_privacy,
      :setting_boost_modal,
      :setting_auto_play_gif,
      notification_emails: %i(follow follow_request reblog favourite mention digest),
      interactions: %i(must_be_follower must_be_following)
    )
  end
end

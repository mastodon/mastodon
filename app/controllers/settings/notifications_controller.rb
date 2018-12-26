# frozen_string_literal: true

class Settings::NotificationsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_body_classes

  def show; end

  def update
    user_settings.update(user_settings_params.to_h)

    if current_user.save
      redirect_to settings_notifications_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :show
    end
  end

  private

  def user_settings
    UserSettingsDecorator.new(current_user)
  end

  def user_settings_params
    params.require(:user).permit(
      notification_emails: %i(follow follow_request reblog favourite mention digest report),
      interactions: %i(must_be_follower must_be_following must_be_following_dm)
    )
  end

  def set_body_classes
    @body_classes = 'admin'
  end
end

# frozen_string_literal: true

class Settings::PreferencesController < ApplicationController
  layout 'auth'

  before_action :authenticate_user!

  def show; end

  def update
    current_user.settings(:notification_emails).follow         = user_params[:notification_emails][:follow]         == '1'
    current_user.settings(:notification_emails).follow_request = user_params[:notification_emails][:follow_request] == '1'
    current_user.settings(:notification_emails).reblog         = user_params[:notification_emails][:reblog]         == '1'
    current_user.settings(:notification_emails).favourite      = user_params[:notification_emails][:favourite]      == '1'
    current_user.settings(:notification_emails).mention        = user_params[:notification_emails][:mention]        == '1'

    current_user.settings(:interactions).must_be_follower  = user_params[:interactions][:must_be_follower]  == '1'
    current_user.settings(:interactions).must_be_following = user_params[:interactions][:must_be_following] == '1'

    if current_user.update(user_params.except(:notification_emails, :interactions))
      redirect_to settings_preferences_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render action: :show
    end
  end

  private

  def user_params
    params.require(:user).permit(:locale, notification_emails: [:follow, :follow_request, :reblog, :favourite, :mention], interactions: [:must_be_follower, :must_be_following])
  end
end

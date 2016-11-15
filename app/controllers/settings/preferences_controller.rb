# frozen_string_literal: true

class Settings::PreferencesController < ApplicationController
  layout 'auth'

  before_action :authenticate_user!

  def show
  end

  def update
    current_user.settings(:notification_emails).follow    = user_params[:notification_emails][:follow]    == '1'
    current_user.settings(:notification_emails).reblog    = user_params[:notification_emails][:reblog]    == '1'
    current_user.settings(:notification_emails).favourite = user_params[:notification_emails][:favourite] == '1'
    current_user.settings(:notification_emails).mention   = user_params[:notification_emails][:mention]   == '1'

    if current_user.save
      redirect_to settings_preferences_path, notice: 'Changes successfully saved!'
    else
      render action: :show
    end
  end

  private

  def user_params
    params.require(:user).permit(notification_emails: [:follow, :reblog, :favourite, :mention])
  end
end

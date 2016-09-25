class SettingsController < ApplicationController
  layout 'auth'
  
  before_action :authenticate_user!
  before_action :set_account

  def show
  end

  def update
    if @account.update(account_params)
      redirect_to settings_path
    else
      render action: :show
    end
  end

  private

  def account_params
    params.require(:account).permit(:display_name, :note, :avatar, :header)
  end

  def set_account
    @account = current_user.account
  end
end

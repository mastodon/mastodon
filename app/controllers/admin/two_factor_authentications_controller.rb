# frozen_string_literal: true

module Admin
  class TwoFactorAuthenticationsController < BaseController
    before_action :set_user

    def destroy
      authorize @user, :disable_2fa?
      @user.disable_two_factor!
      log_action :disable_2fa, @user
      redirect_to admin_accounts_path
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end
  end
end

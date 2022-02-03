# frozen_string_literal: true

module Admin
  class TwoFactorAuthenticationsController < BaseController
    before_action :set_target_user

    def destroy
      authorize @user, :disable_2fa?
      @user.disable_two_factor!
      log_action :disable_2fa, @user
      UserMailer.two_factor_disabled(@user).deliver_later!
      redirect_to admin_account_path(@user.account_id)
    end

    private

    def set_target_user
      @user = User.find(params[:user_id])
    end
  end
end

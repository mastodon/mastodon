# frozen_string_literal: true

module Admin
  class Users::SignInTokenAuthenticationsController < BaseController
    before_action :set_target_user

    def destroy
      authorize @user, :disable_sign_in_token?
      @user.disable_sign_in_token!
      log_action :disable_sign_in_token, @user
      redirect_to admin_account_path(@user.account_id)
    end

    private

    def set_target_user
      @user = User.find(params[:user_id])
    end
  end
end

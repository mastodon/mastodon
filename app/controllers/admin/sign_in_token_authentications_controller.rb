# frozen_string_literal: true

module Admin
  class SignInTokenAuthenticationsController < BaseController
    before_action :set_target_user

    def create
      authorize @user, :enable_sign_in_token_auth?
      @user.update(skip_sign_in_token: false)
      log_action :enable_sign_in_token_auth, @user
      redirect_to admin_account_path(@user.account_id)
    end

    def destroy
      authorize @user, :disable_sign_in_token_auth?
      @user.update(skip_sign_in_token: true)
      log_action :disable_sign_in_token_auth, @user
      redirect_to admin_account_path(@user.account_id)
    end

    private

    def set_target_user
      @user = User.find(params[:user_id])
    end
  end
end

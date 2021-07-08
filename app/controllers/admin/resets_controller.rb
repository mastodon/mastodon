# frozen_string_literal: true

module Admin
  class ResetsController < BaseController
    before_action :set_user

    def create
      authorize @user, :reset_password?
      @user.reset_password!
      log_action :reset_password, @user
      redirect_to admin_account_path(@user.account_id)
    end
  end
end

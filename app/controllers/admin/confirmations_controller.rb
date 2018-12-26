# frozen_string_literal: true

module Admin
  class ConfirmationsController < BaseController
    before_action :set_user

    def create
      authorize @user, :confirm?
      @user.confirm!
      log_action :confirm, @user
      redirect_to admin_accounts_path
    end

    private

    def set_user
      @user = Account.find(params[:account_id]).user || raise(ActiveRecord::RecordNotFound)
    end
  end
end

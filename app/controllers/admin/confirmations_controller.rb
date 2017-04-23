# frozen_string_literal: true

module Admin
  class ConfirmationsController < BaseController
    before_action :set_account

    def create
      @account.user.confirm
      redirect_to admin_accounts_path
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end

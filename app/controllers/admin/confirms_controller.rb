# frozen_string_literal: true

module Admin
  class ConfirmsController < BaseController
    before_action :set_account

    def create
      @account.user.update(confirmed_at: Time.now.utc)
      redirect_to admin_accounts_path
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end

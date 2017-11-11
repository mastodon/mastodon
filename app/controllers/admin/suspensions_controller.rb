# frozen_string_literal: true

module Admin
  class SuspensionsController < BaseController
    before_action :set_account

    def create
      Admin::SuspensionWorker.perform_async(@account.id)
      redirect_to admin_accounts_path
    end

    def destroy
      @account.update(suspended: false)
      redirect_to admin_accounts_path
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end

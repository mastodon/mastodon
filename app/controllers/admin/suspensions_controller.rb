# frozen_string_literal: true

module Admin
  class SuspensionsController < BaseController
    before_action :set_account

    def create
      authorize @account, :suspend?
      Admin::SuspensionWorker.perform_async(@account.id)
      log_action :suspend, @account
      redirect_to admin_accounts_path
    end

    def destroy
      authorize @account, :unsuspend?
      @account.unsuspend!
      log_action :unsuspend, @account
      redirect_to admin_accounts_path
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end

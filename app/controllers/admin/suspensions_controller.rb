# frozen_string_literal: true

module Admin
  class SuspensionsController < BaseController
    before_action :set_account

    def new
      @suspension = Form::AdminSuspensionConfirmation.new
    end

    def create
      authorize @account, :suspend?

      if suspension_params[:acct] == @account.acct
        @account.suspend!
        Admin::SuspensionWorker.perform_async(@account.id)
        log_action :suspend, @account
        redirect_to admin_accounts_path
      else
        redirect_to new_admin_account_suspension_path(@account.id), alert: I18n.t('admin.suspensions.bad_acct_msg')
      end
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

    def suspension_params
      params.require(:form_admin_suspension_confirmation).permit(:acct)
    end
  end
end

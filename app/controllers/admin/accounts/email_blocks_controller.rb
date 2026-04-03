# frozen_string_literal: true

module Admin
  class Accounts::EmailBlocksController < BaseController
    before_action :set_account

    def destroy
      authorize @account, :unblock_email?

      CanonicalEmailBlock.where(reference_account: @account).delete_all

      log_action :unblock_email, @account

      redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.unblocked_email_msg', username: @account.acct)
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end

# frozen_string_literal: true

module Admin
  class Accounts::HeadersController < BaseController
    before_action :set_account

    def destroy
      authorize @account, :remove_header?

      @account.header = nil
      @account.save!

      log_action :remove_header, @account.user

      redirect_to admin_account_path(@account.id), notice: t('admin.accounts.removed_header_msg', username: @account.acct)
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end

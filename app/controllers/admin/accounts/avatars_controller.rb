# frozen_string_literal: true

module Admin
  class Accounts::AvatarsController < BaseController
    before_action :set_account

    def destroy
      authorize @account, :remove_avatar?

      @account.avatar = nil
      @account.save!

      log_action :remove_avatar, @account.user

      redirect_to admin_account_path(@account.id), notice: t('admin.accounts.removed_avatar_msg', username: @account.acct)
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end

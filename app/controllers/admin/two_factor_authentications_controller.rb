# frozen_string_literal: true

module Admin
  class TwoFactorAuthenticationsController < BaseController
    before_action :set_account

    def destroy
      @account.user.otp_required_for_login = false
      @account.user.otp_backup_codes.clear
      @account.user.save!
      redirect_to admin_accounts_path
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end

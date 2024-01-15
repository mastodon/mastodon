# frozen_string_literal: true

module Admin
  class ConfirmationsController < BaseController
    before_action :set_user
    before_action :check_confirmation, only: [:resend]

    def create
      authorize @user, :confirm?
      @user.mark_email_as_confirmed!
      log_action :confirm, @user
      redirect_to admin_accounts_path
    end

    def resend
      authorize @user, :confirm?

      @user.resend_confirmation_instructions

      log_action :resend, @user

      flash[:notice] = I18n.t('admin.accounts.resend_confirmation.success')
      redirect_to admin_accounts_path
    end

    private

    def check_confirmation
      if @user.confirmed?
        flash[:error] = I18n.t('admin.accounts.resend_confirmation.already_confirmed')
        redirect_to admin_accounts_path
      end
    end
  end
end

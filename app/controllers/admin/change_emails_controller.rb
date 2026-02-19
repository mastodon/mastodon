# frozen_string_literal: true

module Admin
  class ChangeEmailsController < BaseController
    before_action :set_account
    before_action :require_local_account!

    def show
      authorize @user, :change_email?
    end

    def update
      authorize @user, :change_email?

      new_email = resource_params.fetch(:unconfirmed_email)

      if new_email != @user.email
        @user.update!(
          unconfirmed_email: new_email,
          # Regenerate the confirmation token:
          confirmation_token: nil
        )

        log_action :change_email, @user

        @user.send_confirmation_instructions
      end

      redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.change_email.changed_msg')
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
      @user = @account.user
    end

    def require_local_account!
      redirect_to admin_account_path(@account.id) unless @account.local? && @account.user.present?
    end

    def resource_params
      params
        .expect(user: [:unconfirmed_email])
    end
  end
end

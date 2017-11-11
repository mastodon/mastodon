# frozen_string_literal: true

module Admin
  class SilencesController < BaseController
    before_action :set_account

    def create
      @account.update(silenced: true)
      redirect_to admin_accounts_path
    end

    def destroy
      @account.update(silenced: false)
      redirect_to admin_accounts_path
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end

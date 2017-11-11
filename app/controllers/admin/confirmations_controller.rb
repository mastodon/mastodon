# frozen_string_literal: true

module Admin
  class ConfirmationsController < BaseController
    def create
      account_user.confirm
      redirect_to admin_accounts_path
    end

    private

    def account_user
      Account.find(params[:account_id]).user || raise(ActiveRecord::RecordNotFound)
    end
  end
end

# frozen_string_literal: true

# TODO: can be removed after 5.0.0
module Admin
  class AccountActionsController < BaseController
    before_action :set_account

    def new
      authorize @account, :show?

      redirect_to new_admin_account_moderation_action_path(account_id: @target_account.id)
    end

    def create
      authorize @account, :show?

      redirect_to new_admin_account_moderation_action_path(account_id: @target_account.id)
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end

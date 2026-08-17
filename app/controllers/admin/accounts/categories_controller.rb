# frozen_string_literal: true

module Admin
  class Accounts::CategoriesController < BaseController
    before_action :set_account

    def show
      authorize @account, :change_categories?
    end

    def update
      authorize @account, :change_categories?

      @account.user.current_account = current_account

      if @account.update(resource_params)
        log_action :change_categories, @account
        redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.categories.changed_msg')
      else
        render :show, status: 422
      end
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end

    def resource_params
      params.expect(account: [category_ids: []])
    end
  end
end

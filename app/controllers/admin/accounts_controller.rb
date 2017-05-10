# frozen_string_literal: true

module Admin
  class AccountsController < BaseController
    def index
      @accounts = filtered_accounts.page(params[:page])
    end

    def show
      @account = Account.find(params[:id])
    end

    private

    def filtered_accounts
      AccountFilter.new(filter_params).results
    end

    def filter_params
      params.permit(
        :local,
        :remote,
        :by_domain,
        :silenced,
        :recent,
        :suspended
      )
    end
  end
end

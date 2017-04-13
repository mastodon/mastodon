# frozen_string_literal: true

module Admin
  class AccountsController < BaseController
    before_action :set_account, except: :index

    def index
      @accounts = filtered_accounts.page(params[:page])
    end

    def show; end

    def suspend
      Admin::SuspensionWorker.perform_async(@account.id)
      redirect_to admin_accounts_path
    end

    def unsuspend
      @account.update(suspended: false)
      redirect_to admin_accounts_path
    end

    def silence
      @account.update(silenced: true)
      redirect_to admin_accounts_path
    end

    def unsilence
      @account.update(silenced: false)
      redirect_to admin_accounts_path
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
        :suspended,
      )
    end

    def set_account
      @account = Account.find(params[:id])
    end
  end
end

# frozen_string_literal: true

module Admin
  class AccountsController < BaseController
    before_action :set_account, only: [:show, :subscribe, :unsubscribe, :redownload]
    before_action :require_remote_account!, only: [:subscribe, :unsubscribe, :redownload]

    def index
      @accounts = filtered_accounts.page(params[:page])
    end

    def show; end

    def subscribe
      Pubsubhubbub::SubscribeWorker.perform_async(@account.id)
      redirect_to admin_account_path(@account.id)
    end

    def unsubscribe
      Pubsubhubbub::UnsubscribeWorker.perform_async(@account.id)
      redirect_to admin_account_path(@account.id)
    end

    def redownload
      @account.reset_avatar!
      @account.reset_header!
      @account.save!

      redirect_to admin_account_path(@account.id)
    end

    private

    def set_account
      @account = Account.find(params[:id])
    end

    def require_remote_account!
      redirect_to admin_account_path(@account.id) if @account.local?
    end

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
        :username,
        :display_name,
        :email,
        :ip
      )
    end
  end
end

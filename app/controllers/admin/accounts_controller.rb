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
      Account.filter(filter_params)
    end

    def filter_params
      filters = [
        :local,
        :remote,
        :by_domain,
        :silenced,
        :recent,
        :suspended,
        :username,
        :display_name,
        :email,
      ]

      filters << :ip if valid_ip?(params[:ip])

      params.permit(filters)
    end

    def valid_ip?(value)
      IPAddr.new(value)
      true
    rescue IPAddr::Error
      false
    end
  end
end

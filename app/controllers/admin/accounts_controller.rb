# frozen_string_literal: true

module Admin
  class AccountsController < BaseController
    before_action :set_account, only: [:show, :subscribe, :unsubscribe, :redownload, :remove_avatar, :enable, :disable, :memorialize]
    before_action :require_remote_account!, only: [:subscribe, :unsubscribe, :redownload]
    before_action :require_local_account!, only: [:enable, :disable, :memorialize]

    def index
      authorize :account, :index?
      @accounts = filtered_accounts.page(params[:page])
    end

    def show
      authorize @account, :show?
      @account_moderation_note = current_account.account_moderation_notes.new(target_account: @account)
      @moderation_notes = @account.targeted_moderation_notes.latest
    end

    def subscribe
      authorize @account, :subscribe?
      Pubsubhubbub::SubscribeWorker.perform_async(@account.id)
      redirect_to admin_account_path(@account.id)
    end

    def unsubscribe
      authorize @account, :unsubscribe?
      Pubsubhubbub::UnsubscribeWorker.perform_async(@account.id)
      redirect_to admin_account_path(@account.id)
    end

    def memorialize
      authorize @account, :memorialize?
      @account.memorialize!
      log_action :memorialize, @account
      redirect_to admin_account_path(@account.id)
    end

    def enable
      authorize @account.user, :enable?
      @account.user.enable!
      log_action :enable, @account.user
      redirect_to admin_account_path(@account.id)
    end

    def disable
      authorize @account.user, :disable?
      @account.user.disable!
      log_action :disable, @account.user
      redirect_to admin_account_path(@account.id)
    end

    def redownload
      authorize @account, :redownload?

      @account.reset_avatar!
      @account.reset_header!
      @account.save!

      redirect_to admin_account_path(@account.id)
    end

    def remove_avatar
      authorize @account, :remove_avatar?

      @account.avatar = nil
      @account.save!

      log_action :remove_avatar, @account.user

      redirect_to admin_account_path(@account.id)
    end

    private

    def set_account
      @account = Account.find(params[:id])
    end

    def require_remote_account!
      redirect_to admin_account_path(@account.id) if @account.local?
    end

    def require_local_account!
      redirect_to admin_account_path(@account.id) unless @account.local? && @account.user.present?
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
        :alphabetic,
        :suspended,
        :username,
        :display_name,
        :email,
        :ip,
        :staff
      )
    end
  end
end

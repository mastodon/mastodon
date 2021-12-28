# frozen_string_literal: true

module Admin
  class AccountsController < BaseController
    before_action :set_account, except: [:index, :batch]
    before_action :require_remote_account!, only: [:redownload]
    before_action :require_local_account!, only: [:enable, :memorialize, :approve, :reject]

    def index
      authorize :account, :index?

      @accounts = filtered_accounts.page(params[:page])
      @form     = Form::AccountBatch.new
    end

    def batch
      @form = Form::AccountBatch.new(form_account_batch_params.merge(current_account: current_account, action: action_from_button))
      @form.save
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.accounts.no_account_selected')
    ensure
      redirect_to admin_accounts_path(filter_params)
    end

    def show
      authorize @account, :show?

      @deletion_request        = @account.deletion_request
      @account_moderation_note = current_account.account_moderation_notes.new(target_account: @account)
      @moderation_notes        = @account.targeted_moderation_notes.latest
      @warnings                = @account.strikes.custom.latest
      @domain_block            = DomainBlock.rule_for(@account.domain)
    end

    def memorialize
      authorize @account, :memorialize?
      @account.memorialize!
      log_action :memorialize, @account
      redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.memorialized_msg', username: @account.acct)
    end

    def enable
      authorize @account.user, :enable?
      @account.user.enable!
      log_action :enable, @account.user
      redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.enabled_msg', username: @account.acct)
    end

    def approve
      authorize @account.user, :approve?
      @account.user.approve!
      redirect_to admin_accounts_path(status: 'pending'), notice: I18n.t('admin.accounts.approved_msg', username: @account.acct)
    end

    def reject
      authorize @account.user, :reject?
      DeleteAccountService.new.call(@account, reserve_email: false, reserve_username: false)
      redirect_to admin_accounts_path(status: 'pending'), notice: I18n.t('admin.accounts.rejected_msg', username: @account.acct)
    end

    def destroy
      authorize @account, :destroy?
      Admin::AccountDeletionWorker.perform_async(@account.id)
      redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.destroyed_msg', username: @account.acct)
    end

    def unsensitive
      authorize @account, :unsensitive?
      @account.unsensitize!
      log_action :unsensitive, @account
      redirect_to admin_account_path(@account.id)
    end

    def unsilence
      authorize @account, :unsilence?
      @account.unsilence!
      log_action :unsilence, @account
      redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.unsilenced_msg', username: @account.acct)
    end

    def unsuspend
      authorize @account, :unsuspend?
      @account.unsuspend!
      Admin::UnsuspensionWorker.perform_async(@account.id)
      log_action :unsuspend, @account
      redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.unsuspended_msg', username: @account.acct)
    end

    def redownload
      authorize @account, :redownload?

      @account.update!(last_webfingered_at: nil)
      ResolveAccountService.new.call(@account)

      redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.redownloaded_msg', username: @account.acct)
    end

    def remove_avatar
      authorize @account, :remove_avatar?

      @account.avatar = nil
      @account.save!

      log_action :remove_avatar, @account.user

      redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.removed_avatar_msg', username: @account.acct)
    end

    def remove_header
      authorize @account, :remove_header?

      @account.header = nil
      @account.save!

      log_action :remove_header, @account.user

      redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.removed_header_msg', username: @account.acct)
    end

    def unblock_email
      authorize @account, :unblock_email?

      CanonicalEmailBlock.where(reference_account: @account).delete_all

      log_action :unblock_email, @account

      redirect_to admin_account_path(@account.id), notice: I18n.t('admin.accounts.unblocked_email_msg', username: @account.acct)
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
      AccountFilter.new(filter_params.with_defaults(order: 'recent')).results
    end

    def filter_params
      params.slice(*AccountFilter::KEYS).permit(*AccountFilter::KEYS)
    end

    def form_account_batch_params
      params.require(:form_account_batch).permit(:action, account_ids: [])
    end

    def action_from_button
      if params[:suspend]
        'suspend'
      elsif params[:approve]
        'approve'
      elsif params[:reject]
        'reject'
      end
    end
  end
end

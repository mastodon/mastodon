# frozen_string_literal: true

module AccountOwnedConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, if: -> { whitelist_mode? && request.format != :json }
    before_action :set_account, if: :account_required?
    before_action :check_account_approval, if: :account_required?
    before_action :check_account_suspension, if: :account_required?
    before_action :check_account_confirmation, if: :account_required?
  end

  private

  def account_required?
    true
  end

  def set_account
    @account = Account.find_local!(username_param)
  end

  def username_param
    params[:account_username]
  end

  def check_account_approval
    not_found if @account.local? && @account.user_pending?
  end

  def check_account_confirmation
    not_found if @account.local? && !@account.user_confirmed?
  end

  def check_account_suspension
    if @account.suspended_permanently?
      permanent_suspension_response
    elsif @account.suspended? && !skip_temporary_suspension_response?
      temporary_suspension_response
    end
  end

  def skip_temporary_suspension_response?
    false
  end

  def permanent_suspension_response
    expires_in(3.minutes, public: true)
    gone
  end

  def temporary_suspension_response
    expires_in(3.minutes, public: true)
    not_available_for_legal_reasons
  end
end

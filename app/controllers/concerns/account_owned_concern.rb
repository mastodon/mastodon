# frozen_string_literal: true

module AccountOwnedConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_account, if: :account_required?
    before_action :check_account_approval, if: :account_required?
    before_action :check_account_suspension, if: :account_required?
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

  def check_account_suspension
    expires_in(3.minutes, public: true) && gone if @account.suspended?
  end
end

# frozen_string_literal: true

class StatusFilter
  attr_reader :status, :account

  def initialize(status, account)
    @status = status
    @account = account
  end

  def filtered?
    return false if !account.nil? && account.id == status.account_id
    blocked_by_policy? || (account_present? && filtered_status?) || silenced_account?
  end

  private

  def account_present?
    !account.nil?
  end

  def filtered_status?
    blocking_account? || blocking_domain? || muting_account?
  end

  def blocking_account?
    account.blocking? status.account_id
  end

  def blocking_domain?
    account.domain_blocking? status.account_domain
  end

  def muting_account?
    account.muting? status.account_id
  end

  def silenced_account?
    !account&.silenced? && status_account_silenced? && !account_following_status_account?
  end

  def status_account_silenced?
    status.account.silenced?
  end

  def account_following_status_account?
    account&.following? status.account_id
  end

  def blocked_by_policy?
    !policy_allows_show?
  end

  def policy_allows_show?
    StatusPolicy.new(account, status).show?
  end
end

# frozen_string_literal: true

class StatusPolicy
  attr_reader :account, :status

  def initialize(account, status)
    @account = account
    @status = status
  end

  def show?
    if direct?
      status.account.id == account&.id || status.mentions.where(account: account).exists?
    elsif private?
      status.account.id == account&.id || account&.following?(status.account) || status.mentions.where(account: account).exists?
    else
      account.nil? || !status.account.blocking?(account)
    end
  end

  def reblog?
    !direct? && !private? && show?
  end

  private

  def direct?
    status.direct_visibility?
  end

  def private?
    status.private_visibility?
  end
end

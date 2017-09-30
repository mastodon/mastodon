# frozen_string_literal: true

class StatusPolicy
  attr_reader :account, :status

  def initialize(account, status)
    @account = account
    @status = status
  end

  def show?
    if direct?
      owned? || status.mentions.where(account: account).exists?
    elsif private?
      owned? || account&.following?(status.account) || status.mentions.where(account: account).exists?
    else
      account.nil? || !status.account.blocking?(account)
    end
  end

  def reblog?
    !direct? && !private? && show?
  end

  def destroy?
    admin? || owned?
  end

  alias unreblog? destroy?

  private

  def admin?
    account&.user&.admin?
  end

  def direct?
    status.direct_visibility?
  end

  def owned?
    status.account.id == account&.id
  end

  def private?
    status.private_visibility?
  end
end

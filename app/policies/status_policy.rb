# frozen_string_literal: true

class StatusPolicy
  attr_reader :account, :status

  def initialize(account, status)
    @account = account
    @status = status
  end

  def show?
    if status.direct_visibility?
      status.account.id == account&.id || status.mentions.where(account: account).exists?
    elsif status.private_visibility?
      status.account.id == account&.id || account&.following?(status.account) || status.mentions.where(account: account).exists?
    else
      account.nil? || !status.account.blocking?(account)
    end
  end
end

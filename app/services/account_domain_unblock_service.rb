# frozen_string_literal: true

class AccountDomainUnblockService < BaseService
  def call(account, target_domain)
    account.unblock_domain!(target_domain)
  end
end

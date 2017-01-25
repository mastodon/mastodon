# frozen_string_literal: true

class AccountUnblockDomainService < BaseService
  def call(account, domain)
    block = AccountDomainBlock.find_by(account_id: account.id, target_domain: domain)
    block&.destroy
  end
end

# frozen_string_literal: true

class BlockDomainFromAccountService < BaseService
  def call(account, domain)
    account.block_domain!(domain)
  end
end

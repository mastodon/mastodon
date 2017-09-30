# frozen_string_literal: true

class BlockDomainFromAccountService < BaseService
  def call(account, domain)
    account.block_domain!(domain)
    account.passive_relationships.where(account: Account.where(domain: domain)).delete_all
  end
end

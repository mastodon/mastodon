# frozen_string_literal: true

class AccountDomainBlockService < BaseService
  def call(account, target_domain)
    account.block_domain!(target_domain)
  end
end

# frozen_string_literal: true

class AccountBlockDomainService < BaseService
  def call(account, domain)
    AccountDomainBlock.find_or_create_by!(account_id: account.id, target_domain: domain)
  end
end

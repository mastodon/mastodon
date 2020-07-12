# frozen_string_literal: true

class UnallowDomainService < BaseService
  include DomainControlHelper

  def call(domain_allow)
    suspend_accounts!(domain_allow.domain) if whitelist_mode?

    domain_allow.destroy
  end

  private

  def suspend_accounts!(domain)
    Account.where(domain: domain).find_each do |account|
      SuspendAccountService.new.call(account, reserve_username: false)
    end
  end
end

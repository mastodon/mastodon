# frozen_string_literal: true

class UnallowDomainService < BaseService
  def call(domain_allow)
    Account.where(domain: domain_allow.domain).find_each do |account|
      SuspendAccountService.new.call(account, reserve_username: false)
    end

    domain_allow.destroy
  end
end

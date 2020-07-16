# frozen_string_literal: true

class AfterUnallowDomainService < BaseService
  def call(domain)
    Account.where(domain: domain).find_each do |account|
      SuspendAccountService.new.call(account, reserve_username: false)
    end
  end
end

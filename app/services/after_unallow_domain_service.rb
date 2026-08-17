# frozen_string_literal: true

class AfterUnallowDomainService < BaseService
  def call(domain)
    return if domain.blank?

    Account.remote.where(domain: domain).find_each do |account|
      DeleteAccountService.new.call(account, reserve_username: false)
    end
  end
end

# frozen_string_literal: true

class PurgeDomainService < BaseService
  def call(domain)
    Account.remote.where(domain: domain).reorder(nil).find_each do |account|
      DeleteAccountService.new.call(account, reserve_username: false, skip_side_effects: true)
    end
    CustomEmoji.remote.where(domain: domain).reorder(nil).find_each(&:destroy)
    Instance.refresh
  end
end

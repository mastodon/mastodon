# frozen_string_literal: true

class PurgeDomainService < BaseService
  def call(domain)
    @domain = domain

    purge_accounts!
    purge_emojis!

    Instance.refresh
  end

  def purge_accounts!
    Account.remote.where(domain: @domain).reorder(nil).find_each do |account|
      DeleteAccountService.new.call(account, reserve_username: false, skip_side_effects: true)
    end
  end

  def purge_emojis!
    CustomEmoji.remote.where(domain: @domain).reorder(nil).find_each(&:destroy)
  end
end

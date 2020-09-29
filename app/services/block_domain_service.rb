# frozen_string_literal: true

class BlockDomainService < BaseService
  attr_reader :domain_block

  def call(domain_block, update = false)
    @domain_block = domain_block
    process_domain_block!
    process_retroactive_updates! if update
  end

  private

  def process_retroactive_updates!
    # If the domain block severity has been changed, undo the appropriate limitations
    scope = Account.by_domain_and_subdomains(domain_block.domain)

    scope.where(silenced_at: domain_block.created_at).in_batches.update_all(silenced_at: nil) unless domain_block.silence?
    scope.where(suspended_at: domain_block.created_at).in_batches.update_all(suspended_at: nil) unless domain_block.suspend?
  end

  def process_domain_block!
    if domain_block.silence?
      silence_accounts!
    elsif domain_block.suspend?
      suspend_accounts!
    end

    DomainClearMediaWorker.perform_async(domain_block.id) if domain_block.reject_media?
  end

  def silence_accounts!
    blocked_domain_accounts.without_silenced.in_batches.update_all(silenced_at: @domain_block.created_at)
  end

  def suspend_accounts!
    blocked_domain_accounts.without_suspended.in_batches.update_all(suspended_at: @domain_block.created_at)
    blocked_domain_accounts.where(suspended_at: @domain_block.created_at).reorder(nil).find_each do |account|
      DeleteAccountService.new.call(account, reserve_username: true, suspended_at: @domain_block.created_at)
    end
  end

  def blocked_domain
    domain_block.domain
  end

  def blocked_domain_accounts
    Account.by_domain_and_subdomains(blocked_domain)
  end
end

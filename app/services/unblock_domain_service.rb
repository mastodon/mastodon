# frozen_string_literal: true

class UnblockDomainService < BaseService
  attr_accessor :domain_block

  def call(domain_block)
    @domain_block = domain_block
    process_retroactive_updates
    domain_block.destroy
  end

  def process_retroactive_updates
    blocked_accounts.in_batches.update_all(update_options) unless domain_block.noop?
  end

  def blocked_accounts
    scope = Account.by_domain_and_subdomains(domain_block.domain)

    if domain_block.silence?
      scope.where(silenced_at: @domain_block.created_at)
    else
      scope.where(suspended_at: @domain_block.created_at)
    end
  end

  def update_options
    { domain_block_impact => nil }
  end

  def domain_block_impact
    domain_block.silence? ? :silenced_at : :suspended_at
  end
end

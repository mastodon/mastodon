# frozen_string_literal: true

class UnblockDomainService < BaseService
  attr_accessor :domain_block

  def call(domain_block)
    @domain_block = domain_block
    process_retroactive_updates
    domain_block.destroy
  end

  def process_retroactive_updates
    scope = Account.by_domain_and_subdomains(domain_block.domain)

    scope.where(silenced_at: domain_block.created_at).in_batches.update_all(silenced_at: nil) unless domain_block.noop?
    scope.where(suspended_at: domain_block.created_at).in_batches.update_all(suspended_at: nil, suspension_origin: nil) if domain_block.suspend?
  end
end

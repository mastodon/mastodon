# frozen_string_literal: true

class DomainBlockWorker
  include Sidekiq::Worker

  def perform(domain_block_id, update = false) # rubocop:disable Style/OptionalBooleanParameter
    domain_block = DomainBlock.find_by(id: domain_block_id)
    return true if domain_block.nil?

    BlockDomainService.new.call(domain_block, update:)
  end
end

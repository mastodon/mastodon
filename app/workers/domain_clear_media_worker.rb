# frozen_string_literal: true

class DomainClearMediaWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(domain_block_id)
    ClearDomainMediaService.new.call(DomainBlock.find(domain_block_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end

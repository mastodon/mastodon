# frozen_string_literal: true

class RegenerationWorkerPrio
  include Sidekiq::Worker

  sidekiq_options queue: 'emergency', lock: :until_executed

  def perform(account_id, _ = :home)
    account = Account.find(account_id)
    Rails.logger.info("Regenerating feed for account x #{account_id}")
    PrecomputeFeedService.new.call(account)
  rescue ActiveRecord::RecordNotFound
    true
  end
end

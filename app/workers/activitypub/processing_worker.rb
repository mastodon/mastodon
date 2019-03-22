# frozen_string_literal: true

class ActivityPub::ProcessingWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true

  def perform(account_id, body, delivered_to_account_id = nil)
    ActivityPub::ProcessCollectionService.new.call(body, Account.find(account_id), override_timestamps: true, delivered_to_account_id: delivered_to_account_id, delivery: true)
  end
end

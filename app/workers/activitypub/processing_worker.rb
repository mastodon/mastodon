# frozen_string_literal: true

class ActivityPub::ProcessingWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: 8

  def perform(account_id, body, delivered_to_account_id = nil)
    account = Account.find_by(id: account_id)
    return if account.nil?

    ActivityPub::ProcessCollectionService.new.call(body, account, override_timestamps: true, delivered_to_account_id: delivered_to_account_id, delivery: true)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.debug "Error processing incoming ActivityPub object: #{e}"
  end
end

# frozen_string_literal: true

class ActivityPub::ProcessingWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: 8

  def perform(account_id, body, delivered_to_account_id = nil, headers = {})
    @account                 = Account.find(account_id)
    @body                    = body
    @delivered_to_account_id = delivered_to_account_id
    @headers                 = headers

    process_collection_synchronization!
    process_collection!
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.debug "Error processing incoming ActivityPub payload: #{e}"
  end

  private

  def process_collection_synchronization!
    collection_synchronization = @headers['Collection-Synchronization']

    return if collection_synchronization.blank?

    ActivityPub::ProcessCollectionSynchronizationService.new.call(@account, collection_synchronization)
  end

  def process_collection!
    ActivityPub::ProcessCollectionService.new.call(
      @body,
      @account,
      override_timestamps: true,
      delivered_to_account_id: @delivered_to_account_id,
      delivery: true,
      headers: @headers
    )
  end
end

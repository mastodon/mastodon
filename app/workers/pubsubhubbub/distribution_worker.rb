# frozen_string_literal: true

class Pubsubhubbub::DistributionWorker
  include Sidekiq::Worker

  def perform(stream_entry_id)
    stream_entry = StreamEntry.find(stream_entry_id)
    account      = stream_entry.account
    payload      = AccountsController.render(:show, assigns: { account: account, entries: [stream_entry] }, formats: [:atom])

    Subscription.where(account: account).active.select('id').find_each do |subscription|
      Pubsubhubbub::DeliveryWorker.perform_async(subscription.id, payload)
    end
  end
end

# frozen_string_literal: true

class Pubsubhubbub::DistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(stream_entry_id)
    stream_entry = StreamEntry.find(stream_entry_id)

    return if stream_entry.hidden?

    account = stream_entry.account
    payload = AtomSerializer.render(AtomSerializer.new.feed(account, [stream_entry]))

    Subscription.where(account: account).active.select('id, callback_url').find_each do |subscription|
      Pubsubhubbub::DeliveryWorker.perform_async(subscription.id, payload)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end

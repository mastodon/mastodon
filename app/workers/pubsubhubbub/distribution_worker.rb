# frozen_string_literal: true

class Pubsubhubbub::DistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(stream_entry_ids)
    stream_entries = StreamEntry.where(id: stream_entry_ids).includes(:status).reject { |e| e.status.nil? || e.status.hidden? }

    return if stream_entries.empty?

    @account       = stream_entries.first.account
    @subscriptions = active_subscriptions.to_a

    distribute_public!(stream_entries)
  end

  private

  def distribute_public!(stream_entries)
    @payload = OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.feed(@account, stream_entries))

    Pubsubhubbub::DeliveryWorker.push_bulk(@subscriptions) do |subscription_id|
      [subscription_id, @payload]
    end
  end

  def active_subscriptions
    Subscription.where(account: @account).active.pluck(:id)
  end
end

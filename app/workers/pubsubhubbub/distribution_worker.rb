# frozen_string_literal: true

class Pubsubhubbub::DistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(stream_entry_id)
    stream_entry = StreamEntry.find(stream_entry_id)
    account      = stream_entry.account
    renderer     = AccountsController.renderer.new(method: 'get', http_host: Rails.configuration.x.local_domain, https: Rails.configuration.x.use_https)
    payload      = renderer.render(:show, assigns: { account: account, entries: [stream_entry] }, formats: [:atom])

    Subscription.where(account: account).active.select('id').find_each do |subscription|
      Pubsubhubbub::DeliveryWorker.perform_async(subscription.id, payload)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end

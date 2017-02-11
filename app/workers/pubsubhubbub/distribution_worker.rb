# frozen_string_literal: true

class Pubsubhubbub::DistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(stream_entry_id)
    stream_entry = StreamEntry.find(stream_entry_id)

    # Most hidden stream entries should not be PuSHed,
    # but statuses need to be distributed to trusted
    # followers even when they are hidden
    return if stream_entry.hidden? && stream_entry.activity_type != 'Status'

    account  = stream_entry.account
    renderer = AccountsController.renderer.new(method: 'get', http_host: Rails.configuration.x.local_domain, https: Rails.configuration.x.use_https)
    payload  = renderer.render(:show, assigns: { account: account, entries: [stream_entry] }, formats: [:atom])
    domains  = account.followers_domains

    Subscription.where(account: account).active.select('id, callback_url').find_each do |subscription|
      next unless domains.include?(Addressable::URI.parse(subscription.callback_url).host)
      Pubsubhubbub::DeliveryWorker.perform_async(subscription.id, payload)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end

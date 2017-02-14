# frozen_string_literal: true

class Pubsubhubbub::DistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(stream_entry_id)
    stream_entry = StreamEntry.find(stream_entry_id)

    return if stream_entry.hidden?

    account  = stream_entry.account
    renderer = AccountsController.renderer.new(method: 'get', http_host: Rails.configuration.x.local_domain, https: Rails.configuration.x.use_https)
    payload  = renderer.render(:show, assigns: { account: account, entries: [stream_entry] }, formats: [:atom])
    # domains  = account.followers_domains

    Subscription.where(account: account).active.select('id, callback_url').find_each do |subscription|
      host = Addressable::URI.parse(subscription.callback_url).host
      next if DomainBlock.blocked?(host) # || !domains.include?(host)
      Pubsubhubbub::DeliveryWorker.perform_async(subscription.id, payload)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end

# frozen_string_literal: true

class Pubsubhubbub::RawDistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(xml, source_account_id)
    @account       = Account.find(source_account_id)
    @subscriptions = active_subscriptions.to_a

    Pubsubhubbub::DeliveryWorker.push_bulk(@subscriptions) do |subscription|
      [subscription.id, xml]
    end
  end

  private

  def active_subscriptions
    Subscription.where(account: @account).active.select('id, callback_url, domain')
  end
end

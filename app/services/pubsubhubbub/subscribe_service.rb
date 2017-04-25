# frozen_string_literal: true

class Pubsubhubbub::SubscribeService < BaseService
  def call(account, callback, secret, lease_seconds)
    return ['Invalid topic URL',        422] if account.nil?
    return ['Invalid callback URL',     422] unless !callback.blank? && callback =~ /\A#{URI.regexp(%w(http https))}\z/
    return ['Callback URL not allowed', 403] if DomainBlock.blocked?(Addressable::URI.parse(callback).normalize.host)

    subscription = Subscription.where(account: account, callback_url: callback).first_or_create!(account: account, callback_url: callback)
    Pubsubhubbub::ConfirmationWorker.perform_async(subscription.id, 'subscribe', secret, lease_seconds)

    ['', 202]
  end
end

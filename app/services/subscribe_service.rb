# frozen_string_literal: true

class SubscribeService < BaseService
  def call(account)
    account.secret = SecureRandom.hex

    subscription = account.subscription(api_subscription_url(account.id))
    response     = subscription.subscribe

    if response.code > 299 && response.code < 500 && response.code != 429
      # An error in the 4xx range (except for 429, which is rate limiting)
      # means we're not allowed to subscribe. Fail and move on
      account.secret = ''
      account.save!
    elsif response.code > 199 && response.code < 300
      # Anything in the 2xx range means the subscription will be confirmed
      # asynchronously, we've done what we needed to do
      account.save!
    else
      # What's left is the 5xx range and 429, which means we need to retry
      # at a later time. Fail loudly!
      raise "Subscription attempt failed for #{account.acct} (#{account.hub_url}): HTTP #{response.code}"
    end
  end
end

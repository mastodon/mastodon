# frozen_string_literal: true

class SubscribeService < BaseService
  def call(account)
    return if account.hub_url.blank?

    @account        = account
    @account.secret = SecureRandom.hex

    build_request.perform do |response|
      if response_failed_permanently? response
        # We're not allowed to subscribe. Fail and move on.
        @account.secret = ''
        @account.save!
      elsif response_successful? response
        # The subscription will be confirmed asynchronously.
        @account.save!
      else
        # The response was either a 429 rate limit, or a 5xx error.
        # We need to retry at a later time. Fail loudly!
        raise Mastodon::UnexpectedResponseError, response
      end
    end
  end

  private

  def build_request
    request = Request.new(:post, @account.hub_url, form: subscription_params)
    request.on_behalf_of(some_local_account) if some_local_account
    request
  end

  def subscription_params
    {
      'hub.topic': @account.remote_url,
      'hub.mode': 'subscribe',
      'hub.callback': api_subscription_url(@account.id),
      'hub.verify': 'async',
      'hub.secret': @account.secret,
      'hub.lease_seconds': 7.days.seconds,
    }
  end

  def some_local_account
    @some_local_account ||= Account.local.where(suspended: false).first
  end

  # Any response in the 3xx or 4xx range, except for 429 (rate limit)
  def response_failed_permanently?(response)
    (response.status.redirect? || response.status.client_error?) && !response.status.too_many_requests?
  end

  # Any response in the 2xx range
  def response_successful?(response)
    response.status.success?
  end
end

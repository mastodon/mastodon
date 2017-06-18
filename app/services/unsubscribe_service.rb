# frozen_string_literal: true

class UnsubscribeService < BaseService
  def call(account)
    subscription = account.subscription(api_subscription_url(account.id))
    response = subscription.unsubscribe

    unless response.status.success?
      Rails.logger.debug "PuSH unsubscribe for #{account.acct} failed: #{response.status}"
    end

    account.secret = ''
    account.subscription_expires_at = nil
    account.save!
  rescue HTTP::Error, OpenSSL::SSL::SSLError
    Rails.logger.debug "PuSH subscription request for #{account.acct} could not be made due to HTTP or SSL error"
  end
end

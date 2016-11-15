# frozen_string_literal: true

class SubscribeService < BaseService
  def call(account)
    account.secret = SecureRandom.hex

    subscription = account.subscription(api_subscription_url(account.id))
    response = subscription.subscribe

    unless response.successful?
      account.secret = ''
      Rails.logger.debug "PuSH subscription request for #{account.acct} failed: #{response.message}"
    end

    account.save!
  rescue HTTP::Error, OpenSSL::SSL::SSLError
    Rails.logger.debug "PuSH subscription request for #{account.acct} could not be made due to HTTP or SSL error"
  end
end

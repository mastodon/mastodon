# frozen_string_literal: true

class Pubsubhubbub::ConfirmationWorker
  include Sidekiq::Worker
  include RoutingHelper

  sidekiq_options queue: 'push', retry: false

  attr_reader :subscription, :mode, :secret, :lease_seconds

  def perform(subscription_id, mode, secret = nil, lease_seconds = nil)
    @subscription = Subscription.find(subscription_id)
    @mode = mode
    @secret = secret
    @lease_seconds = lease_seconds
    process_confirmation
  end

  private

  def process_confirmation
    prepare_subscription

    callback_get_with_params
    logger.debug "Confirming PuSH subscription for #{subscription.callback_url} with challenge #{challenge}: #{@callback_response_body}"

    update_subscription
  end

  def update_subscription
    if successful_subscribe?
      subscription.save!
    elsif successful_unsubscribe?
      subscription.destroy!
    end
  end

  def successful_subscribe?
    subscribing? && response_matches_challenge?
  end

  def successful_unsubscribe?
    (unsubscribing? && response_matches_challenge?) || !subscription.confirmed?
  end

  def response_matches_challenge?
    @callback_response_body == challenge
  end

  def subscribing?
    mode == 'subscribe'
  end

  def unsubscribing?
    mode == 'unsubscribe'
  end

  def callback_get_with_params
    Request.new(:get, subscription.callback_url, params: callback_params).perform do |response|
      @callback_response_body = response.body_with_limit
    end
  end

  def callback_params
    {
      'hub.topic': account_url(subscription.account, format: :atom),
      'hub.mode': mode,
      'hub.challenge': challenge,
      'hub.lease_seconds': subscription.lease_seconds,
    }
  end

  def prepare_subscription
    subscription.secret = secret
    subscription.lease_seconds = lease_seconds
    subscription.confirmed = true
  end

  def challenge
    @_challenge ||= SecureRandom.hex
  end
end

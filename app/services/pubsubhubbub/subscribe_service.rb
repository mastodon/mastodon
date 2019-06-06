# frozen_string_literal: true

class Pubsubhubbub::SubscribeService < BaseService
  URL_PATTERN = /\A#{URI.regexp(%w(http https))}\z/

  attr_reader :account, :callback, :secret,
              :lease_seconds, :domain

  def call(account, callback, secret, lease_seconds, verified_domain = nil)
    @account       = account
    @callback      = Addressable::URI.parse(callback).normalize.to_s
    @secret        = secret
    @lease_seconds = lease_seconds
    @domain        = verified_domain

    process_subscribe
  end

  private

  def process_subscribe
    if account.nil?
      ['Invalid topic URL', 422]
    elsif !valid_callback?
      ['Invalid callback URL', 422]
    elsif blocked_domain?
      ['Callback URL not allowed', 403]
    else
      confirm_subscription
      ['', 202]
    end
  end

  def confirm_subscription
    subscription = locate_subscription
    Pubsubhubbub::ConfirmationWorker.perform_async(subscription.id, 'subscribe', secret, lease_seconds)
  end

  def valid_callback?
    callback.present? && callback =~ URL_PATTERN
  end

  def blocked_domain?
    DomainBlock.blocked? Addressable::URI.parse(callback).host
  end

  def locate_subscription
    subscription = Subscription.find_or_initialize_by(account: account, callback_url: callback)
    subscription.domain = domain
    subscription.save!
    subscription
  end
end

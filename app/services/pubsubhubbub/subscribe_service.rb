# frozen_string_literal: true

class Pubsubhubbub::SubscribeService < BaseService
  URL_PATTERN = /\A#{URI.regexp(%w(http https))}\z/

  attr_reader :account, :callback, :secret, :lease_seconds

  def call(account, callback, secret, lease_seconds)
    @account       = account
    @callback      = Addressable::URI.parse(callback).normalize.to_s
    @secret        = secret
    @lease_seconds = lease_seconds

    process_subscribe
  end

  private

  def process_subscribe
    case subscribe_status
    when :invalid_topic
      ['Invalid topic URL', 422]
    when :invalid_callback
      ['Invalid callback URL', 422]
    when :callback_not_allowed
      ['Callback URL not allowed', 403]
    when :valid
      confirm_subscription
      ['', 202]
    end
  end

  def subscribe_status
    if account.nil?
      :invalid_topic
    elsif !valid_callback?
      :invalid_callback
    elsif blocked_domain?
      :callback_not_allowed
    else
      :valid
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
    Subscription.where(account: account, callback_url: callback).first_or_create!(account: account, callback_url: callback)
  end
end

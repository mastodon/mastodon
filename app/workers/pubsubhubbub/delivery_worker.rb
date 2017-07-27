# frozen_string_literal: true

class Pubsubhubbub::DeliveryWorker
  include Sidekiq::Worker
  include RoutingHelper

  sidekiq_options queue: 'push', retry: 3, dead: false

  sidekiq_retry_in do |count|
    5 * (count + 1)
  end

  attr_reader :subscription, :payload

  def perform(subscription_id, payload)
    @subscription = Subscription.find(subscription_id)
    @payload = payload
    process_delivery unless blocked_domain?
  rescue => e
    raise e.class, "Delivery failed for #{subscription&.callback_url}: #{e.message}"
  end

  private

  def process_delivery
    payload_delivery

    raise Mastodon::UnexpectedResponseError, payload_delivery unless response_successful?

    subscription.touch(:last_successful_delivery_at)
  end

  def payload_delivery
    @_payload_delivery ||= callback_post_payload
  end

  def callback_post_payload
    request = Request.new(:post, subscription.callback_url, body: payload)
    request.add_headers(headers)
    request.perform
  end

  def blocked_domain?
    DomainBlock.blocked?(host)
  end

  def host
    Addressable::URI.parse(subscription.callback_url).normalized_host
  end

  def headers
    {
      'Content-Type' => 'application/atom+xml',
      'Link' => link_header,
    }.merge(signature_headers.to_h)
  end

  def link_header
    LinkHeader.new([hub_link_header, self_link_header]).to_s
  end

  def hub_link_header
    [api_push_url, [%w(rel hub)]]
  end

  def self_link_header
    [account_url(subscription.account, format: :atom), [%w(rel self)]]
  end

  def signature_headers
    { 'X-Hub-Signature' => payload_signature } if subscription.secret?
  end

  def payload_signature
    "sha1=#{hmac_payload_digest}"
  end

  def hmac_payload_digest
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), subscription.secret, payload)
  end

  def response_successful?
    payload_delivery.code > 199 && payload_delivery.code < 300
  end
end

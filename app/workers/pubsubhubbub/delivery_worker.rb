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
  end

  private

  def process_delivery
    payload_delivery

    raise "Delivery failed for #{subscription.callback_url}: HTTP #{payload_delivery.code}" unless response_successful?

    subscription.touch(:last_successful_delivery_at)
  end

  def payload_delivery
    @_payload_delivery ||= callback_post_payload
  end

  def callback_post_payload
    HTTP.timeout(:per_operation, write: 50, connect: 20, read: 50)
        .headers(headers)
        .post(subscription.callback_url, body: payload)
  end

  def blocked_domain?
    DomainBlock.blocked?(host)
  end

  def host
    Addressable::URI.parse(subscription.callback_url).normalize.host
  end

  def headers
    {
      'User-Agent' => 'Mastodon/PubSubHubbub',
      'Content-Type' => 'application/atom+xml',
      'Link' => link_headers,
    }.merge(signature_headers.to_h)
  end

  def link_headers
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

  def response_failed_permanently?(response)
    response.code > 299 && response.code < 500 && response.code != 429
  end

  def response_successful?(response)
    response.code > 199 && response.code < 300
  end
end

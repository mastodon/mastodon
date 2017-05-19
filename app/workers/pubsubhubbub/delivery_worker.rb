# frozen_string_literal: true
#
# Mastodon, a GNU Social-compatible microblogging server
# Copyright (C) 2016-2017 Eugen Rochko & al (see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

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
end

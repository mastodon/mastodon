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

  def perform(subscription_id, payload)
    subscription = Subscription.find(subscription_id)
    headers      = {}
    host         = Addressable::URI.parse(subscription.callback_url).normalize.host

    return if DomainBlock.blocked?(host)

    headers['User-Agent']      = 'Mastodon/PubSubHubbub'
    headers['Link']            = LinkHeader.new([[api_push_url, [%w(rel hub)]], [account_url(subscription.account, format: :atom), [%w(rel self)]]]).to_s
    headers['X-Hub-Signature'] = signature(subscription.secret, payload) if subscription.secret?

    response = HTTP.timeout(:per_operation, write: 50, connect: 20, read: 50)
                   .headers(headers)
                   .post(subscription.callback_url, body: payload)

    return subscription.destroy! if response_failed_permanently?(response) # HTTP 4xx means error is not temporary, except for 429 (throttling)
    raise "Delivery failed for #{subscription.callback_url}: HTTP #{response.code}" unless response_successful?(response)

    subscription.touch(:last_successful_delivery_at)
  end

  private

  def signature(secret, payload)
    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, payload)
    "sha1=#{hmac}"
  end

  def response_failed_permanently?(response)
    response.code > 299 && response.code < 500 && response.code != 429
  end

  def response_successful?(response)
    response.code > 199 && response.code < 300
  end
end

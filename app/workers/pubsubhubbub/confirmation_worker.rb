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

    confirm_callback
    logger.debug "Confirming PuSH subscription for #{subscription.callback_url} with challenge #{challenge}: #{callback_response_body}"

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
    callback_response_body == challenge
  end

  def subscribing?
    mode == 'subscribe'
  end

  def unsubscribing?
    mode == 'unsubscribe'
  end

  def confirm_callback
    @_confirm_callback ||= callback_get_with_params
  end

  def callback_get_with_params
    HTTP.headers(user_agent: 'Mastodon/PubSubHubbub')
        .timeout(:per_operation, write: 20, connect: 20, read: 50)
        .get(subscription.callback_url, params: callback_params)
  end

  def callback_response_body
    confirm_callback.body.to_s
  end

  def callback_params
    {
      'hub.topic' => account_url(subscription.account, format: :atom),
      'hub.mode' => mode,
      'hub.challenge' => challenge,
      'hub.lease_seconds' => subscription.lease_seconds,
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

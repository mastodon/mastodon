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

  def perform(subscription_id, mode, secret = nil, lease_seconds = nil)
    subscription = Subscription.find(subscription_id)
    challenge    = SecureRandom.hex

    subscription.secret        = secret
    subscription.lease_seconds = lease_seconds
    subscription.confirmed     = true

    response = HTTP.headers(user_agent: 'Mastodon/PubSubHubbub')
                   .timeout(:per_operation, write: 20, connect: 20, read: 50)
                   .get(subscription.callback_url, params: {
                          'hub.topic' => account_url(subscription.account, format: :atom),
                          'hub.mode'          => mode,
                          'hub.challenge'     => challenge,
                          'hub.lease_seconds' => subscription.lease_seconds,
                        })

    body = response.body.to_s

    logger.debug "Confirming PuSH subscription for #{subscription.callback_url} with challenge #{challenge}: #{body}"

    if mode == 'subscribe' && body == challenge
      subscription.save!
    elsif (mode == 'unsubscribe' && body == challenge) || !subscription.confirmed?
      subscription.destroy!
    end
  end
end

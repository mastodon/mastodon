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

class SubscribeService < BaseService
  def call(account)
    account.secret = SecureRandom.hex

    subscription = account.subscription(api_subscription_url(account.id))
    response     = subscription.subscribe

    if response_failed_permanently?(response)
      # We're not allowed to subscribe. Fail and move on.
      account.secret = ''
      account.save!
    elsif response_successful?(response)
      # The subscription will be confirmed asynchronously.
      account.save!
    else
      # The response was either a 429 rate limit, or a 5xx error.
      # We need to retry at a later time. Fail loudly!
      raise "Subscription attempt failed for #{account.acct} (#{account.hub_url}): HTTP #{response.code}"
    end
  end

  private

  # Any response in the 3xx or 4xx range, except for 429 (rate limit)
  def response_failed_permanently?(response)
    (response.status.redirect? || response.status.client_error?) && !response.status.too_many_requests?
  end

  # Any response in the 2xx range
  def response_successful?(response)
    response.status.success?
  end
end

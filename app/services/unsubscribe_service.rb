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

class UnsubscribeService < BaseService
  def call(account)
    subscription = account.subscription(api_subscription_url(account.id))
    response = subscription.unsubscribe

    unless response.status.success?
      Rails.logger.debug "PuSH unsubscribe for #{account.acct} failed: #{response.status}"
    end

    account.secret = ''
    account.subscription_expires_at = nil
    account.save!
  rescue HTTP::Error, OpenSSL::SSL::SSLError
    Rails.logger.debug "PuSH subscription request for #{account.acct} could not be made due to HTTP or SSL error"
  end
end

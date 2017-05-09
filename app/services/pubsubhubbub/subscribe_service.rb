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

class Pubsubhubbub::SubscribeService < BaseService
  def call(account, callback, secret, lease_seconds)
    return ['Invalid topic URL',        422] if account.nil?
    return ['Invalid callback URL',     422] unless !callback.blank? && callback =~ /\A#{URI.regexp(%w(http https))}\z/
    return ['Callback URL not allowed', 403] if DomainBlock.blocked?(Addressable::URI.parse(callback).normalize.host)

    subscription = Subscription.where(account: account, callback_url: callback).first_or_create!(account: account, callback_url: callback)
    Pubsubhubbub::ConfirmationWorker.perform_async(subscription.id, 'subscribe', secret, lease_seconds)

    ['', 202]
  end
end

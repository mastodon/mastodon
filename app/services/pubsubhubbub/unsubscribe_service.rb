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

class Pubsubhubbub::UnsubscribeService < BaseService
  attr_reader :account, :callback

  def call(account, callback)
    @account  = account
    @callback = Addressable::URI.parse(callback).normalize.to_s

    process_unsubscribe
  end

  private

  def process_unsubscribe
    if account.nil?
      ['Invalid topic URL', 422]
    else
      confirm_unsubscribe unless subscription.nil?
      ['', 202]
    end
  end

  def confirm_unsubscribe
    Pubsubhubbub::ConfirmationWorker.perform_async(subscription.id, 'unsubscribe')
  end

  def subscription
    @_subscription ||= Subscription.find_by(account: account, callback_url: callback)
  end
end

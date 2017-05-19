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
  URL_PATTERN = /\A#{URI.regexp(%w(http https))}\z/

  attr_reader :account, :callback, :secret, :lease_seconds

  def call(account, callback, secret, lease_seconds)
    @account       = account
    @callback      = Addressable::URI.parse(callback).normalize.to_s
    @secret        = secret
    @lease_seconds = lease_seconds

    process_subscribe
  end

  private

  def process_subscribe
    case subscribe_status
    when :invalid_topic
      ['Invalid topic URL', 422]
    when :invalid_callback
      ['Invalid callback URL', 422]
    when :callback_not_allowed
      ['Callback URL not allowed', 403]
    when :valid
      confirm_subscription
      ['', 202]
    end
  end

  def subscribe_status
    if account.nil?
      :invalid_topic
    elsif !valid_callback?
      :invalid_callback
    elsif blocked_domain?
      :callback_not_allowed
    else
      :valid
    end
  end

  def confirm_subscription
    subscription = locate_subscription
    Pubsubhubbub::ConfirmationWorker.perform_async(subscription.id, 'subscribe', secret, lease_seconds)
  end

  def valid_callback?
    callback.present? && callback =~ URL_PATTERN
  end

  def blocked_domain?
    DomainBlock.blocked? Addressable::URI.parse(callback).host
  end

  def locate_subscription
    Subscription.where(account: account, callback_url: callback).first_or_create!(account: account, callback_url: callback)
  end
end

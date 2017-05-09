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

class NotifyService < BaseService
  def call(recipient, activity)
    @recipient    = recipient
    @activity     = activity
    @notification = Notification.new(account: @recipient, activity: @activity)

    return if recipient.user.nil? || blocked?

    create_notification
    send_email if email_enabled?
  rescue ActiveRecord::RecordInvalid
    return
  end

  private

  def blocked_mention?
    FeedManager.instance.filter?(:mentions, @notification.mention.status, @recipient.id)
  end

  def blocked_favourite?
    false
  end

  def blocked_follow?
    false
  end

  def blocked_reblog?
    false
  end

  def blocked_follow_request?
    false
  end

  def blocked?
    blocked   = @recipient.suspended?                                                                                              # Skip if the recipient account is suspended anyway
    blocked ||= @recipient.id == @notification.from_account.id                                                                     # Skip for interactions with self
    blocked ||= @recipient.blocking?(@notification.from_account)                                                                   # Skip for blocked accounts
    blocked ||= (@notification.from_account.silenced? && !@recipient.following?(@notification.from_account))                       # Hellban
    blocked ||= (@recipient.user.settings.interactions['must_be_follower']  && !@notification.from_account.following?(@recipient)) # Options
    blocked ||= (@recipient.user.settings.interactions['must_be_following'] && !@recipient.following?(@notification.from_account)) # Options
    blocked ||= send("blocked_#{@notification.type}?")                                                                             # Type-dependent filters
    blocked
  end

  def create_notification
    @notification.save!
    return unless @notification.browserable?
    Redis.current.publish("timeline:#{@recipient.id}", Oj.dump(event: :notification, payload: InlineRenderer.render(@notification, @recipient, 'api/v1/notifications/show')))
  end

  def send_email
    NotificationMailer.public_send(@notification.type, @recipient, @notification).deliver_later
  end

  def email_enabled?
    @recipient.user.settings.notification_emails[@notification.type.to_s]
  end
end

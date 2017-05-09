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

class NotificationMailer < ApplicationMailer
  helper StreamEntriesHelper

  def mention(recipient, notification)
    @me     = recipient
    @status = notification.target_status

    locale_for_account(@me) do
      mail to: @me.user.email, subject: I18n.t('notification_mailer.mention.subject', name: @status.account.acct)
    end
  end

  def follow(recipient, notification)
    @me      = recipient
    @account = notification.from_account

    locale_for_account(@me) do
      mail to: @me.user.email, subject: I18n.t('notification_mailer.follow.subject', name: @account.acct)
    end
  end

  def favourite(recipient, notification)
    @me      = recipient
    @account = notification.from_account
    @status  = notification.target_status

    locale_for_account(@me) do
      mail to: @me.user.email, subject: I18n.t('notification_mailer.favourite.subject', name: @account.acct)
    end
  end

  def reblog(recipient, notification)
    @me      = recipient
    @account = notification.from_account
    @status  = notification.target_status

    locale_for_account(@me) do
      mail to: @me.user.email, subject: I18n.t('notification_mailer.reblog.subject', name: @account.acct)
    end
  end

  def follow_request(recipient, notification)
    @me      = recipient
    @account = notification.from_account

    locale_for_account(@me) do
      mail to: @me.user.email, subject: I18n.t('notification_mailer.follow_request.subject', name: @account.acct)
    end
  end

  def digest(recipient, opts = {})
    @me            = recipient
    @since         = opts[:since] || @me.user.last_emailed_at || @me.user.current_sign_in_at
    @notifications = Notification.where(account: @me, activity_type: 'Mention').where('created_at > ?', @since)
    @follows_since = Notification.where(account: @me, activity_type: 'Follow').where('created_at > ?', @since).count

    return if @notifications.empty?

    locale_for_account(@me) do
      mail to: @me.user.email,
           subject: I18n.t(
             :subject,
             scope: [:notification_mailer, :digest],
             count: @notifications.size
           )
    end
  end

  private

  def locale_for_account(account)
    I18n.with_locale(account.user_locale || I18n.default_locale) do
      yield
    end
  end
end

# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  helper StreamEntriesHelper

  def mention(recipient, notification)
    @me     = recipient
    @status = notification.target_status

    I18n.with_locale(@me.user.locale || I18n.default_locale) do
      mail to: @me.user.email, subject: I18n.t('notification_mailer.mention.subject', name: @status.account.acct)
    end
  end

  def follow(recipient, notification)
    @me      = recipient
    @account = notification.from_account

    I18n.with_locale(@me.user.locale || I18n.default_locale) do
      mail to: @me.user.email, subject: I18n.t('notification_mailer.follow.subject', name: @account.acct)
    end
  end

  def favourite(recipient, notification)
    @me      = recipient
    @account = notification.from_account
    @status  = notification.target_status

    I18n.with_locale(@me.user.locale || I18n.default_locale) do
      mail to: @me.user.email, subject: I18n.t('notification_mailer.favourite.subject', name: @account.acct)
    end
  end

  def reblog(recipient, notification)
    @me      = recipient
    @account = notification.from_account
    @status  = notification.target_status

    I18n.with_locale(@me.user.locale || I18n.default_locale) do
      mail to: @me.user.email, subject: I18n.t('notification_mailer.reblog.subject', name: @account.acct)
    end
  end
end

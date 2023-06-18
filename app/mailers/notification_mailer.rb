# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  helper :accounts
  helper :statuses

  helper RoutingHelper

  def mention(recipient, notification)
    @me     = recipient
    @user   = recipient.user
    @type   = 'mention'
    @status = notification.target_status

    return unless @user.functional? && @status.present?

    locale_for_account(@me) do
      thread_by_conversation(@status.conversation)
      mail to: email_address_with_name(@user.email, @me.username), subject: I18n.t('notification_mailer.mention.subject', name: @status.account.acct)
    end
  end

  def follow(recipient, notification)
    @me      = recipient
    @user    = recipient.user
    @type    = 'follow'
    @account = notification.from_account

    return unless @user.functional?

    locale_for_account(@me) do
      mail to: email_address_with_name(@user.email, @me.username), subject: I18n.t('notification_mailer.follow.subject', name: @account.acct)
    end
  end

  def favourite(recipient, notification)
    @me      = recipient
    @user    = recipient.user
    @type    = 'favourite'
    @account = notification.from_account
    @status  = notification.target_status

    return unless @user.functional? && @status.present?

    locale_for_account(@me) do
      thread_by_conversation(@status.conversation)
      mail to: email_address_with_name(@user.email, @me.username), subject: I18n.t('notification_mailer.favourite.subject', name: @account.acct)
    end
  end

  def reblog(recipient, notification)
    @me      = recipient
    @user    = recipient.user
    @type    = 'reblog'
    @account = notification.from_account
    @status  = notification.target_status

    return unless @user.functional? && @status.present?

    locale_for_account(@me) do
      thread_by_conversation(@status.conversation)
      mail to: email_address_with_name(@user.email, @me.username), subject: I18n.t('notification_mailer.reblog.subject', name: @account.acct)
    end
  end

  def follow_request(recipient, notification)
    @me      = recipient
    @user    = recipient.user
    @type    = 'follow_request'
    @account = notification.from_account

    return unless @user.functional?

    locale_for_account(@me) do
      mail to: email_address_with_name(@user.email, @me.username), subject: I18n.t('notification_mailer.follow_request.subject', name: @account.acct)
    end
  end

  private

  def thread_by_conversation(conversation)
    return if conversation.nil?

    msg_id = "<conversation-#{conversation.id}.#{conversation.created_at.strftime('%Y-%m-%d')}@#{Rails.configuration.x.local_domain}>"

    headers['In-Reply-To'] = msg_id
    headers['References']  = msg_id
  end
end

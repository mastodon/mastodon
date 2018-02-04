# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  helper :stream_entries

  add_template_helper RoutingHelper

  def mention(recipient, notification)
    @me     = recipient
    @status = notification.target_status

    return if @me.user.disabled? || @status.nil?

    locale_for_account(@me) do
      thread_by_conversation(@status.conversation)
      mail to: @me.user.email, subject: I18n.t('notification_mailer.mention.subject', name: @status.account.acct)
    end
  end

  def follow(recipient, notification)
    @me      = recipient
    @account = notification.from_account

    return if @me.user.disabled?

    locale_for_account(@me) do
      mail to: @me.user.email, subject: I18n.t('notification_mailer.follow.subject', name: @account.acct)
    end
  end

  def favourite(recipient, notification)
    @me      = recipient
    @account = notification.from_account
    @status  = notification.target_status

    return if @me.user.disabled? || @status.nil?

    locale_for_account(@me) do
      thread_by_conversation(@status.conversation)
      mail to: @me.user.email, subject: I18n.t('notification_mailer.favourite.subject', name: @account.acct)
    end
  end

  def reblog(recipient, notification)
    @me      = recipient
    @account = notification.from_account
    @status  = notification.target_status

    return if @me.user.disabled? || @status.nil?

    locale_for_account(@me) do
      thread_by_conversation(@status.conversation)
      mail to: @me.user.email, subject: I18n.t('notification_mailer.reblog.subject', name: @account.acct)
    end
  end

  def follow_request(recipient, notification)
    @me      = recipient
    @account = notification.from_account

    return if @me.user.disabled?

    locale_for_account(@me) do
      mail to: @me.user.email, subject: I18n.t('notification_mailer.follow_request.subject', name: @account.acct)
    end
  end

  def digest(recipient, **opts)
    @me            = recipient
    @since         = opts[:since] || @me.user.last_emailed_at || @me.user.current_sign_in_at
    @notifications = Notification.where(account: @me, activity_type: 'Mention').where('created_at > ?', @since)
    @follows_since = Notification.where(account: @me, activity_type: 'Follow').where('created_at > ?', @since).count

    return if @me.user.disabled? || @notifications.empty?

    locale_for_account(@me) do
      mail to: @me.user.email,
           subject: I18n.t(:subject, scope: [:notification_mailer, :digest], count: @notifications.size)
    end
  end

  private

  def thread_by_conversation(conversation)
    return if conversation.nil?
    msg_id = "<conversation-#{conversation.id}.#{conversation.created_at.strftime('%Y-%m-%d')}@#{Rails.configuration.x.local_domain}>"
    headers['In-Reply-To'] = msg_id
    headers['References'] = msg_id
  end
end

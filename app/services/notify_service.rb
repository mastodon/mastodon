# frozen_string_literal: true

class NotifyService < BaseService
  def call(recipient, activity)
    @recipient    = recipient
    @activity     = activity
    @notification = Notification.new(account: @recipient, activity: @activity)

    return if blocked?

    create_notification
    send_email if email_enabled?
  rescue ActiveRecord::RecordInvalid
    return
  end

  private

  def blocked_mention?
    FeedManager.instance.filter?(:mentions, @notification.mention.status, @recipient)
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

  def blocked?
    blocked   = false
    blocked ||= @recipient.id == @notification.from_account.id
    blocked ||= @recipient.blocking?(@notification.from_account)
    blocked ||= send("blocked_#{@notification.type}?")
    blocked
  end

  def create_notification
    @notification.save!
    FeedManager.instance.broadcast(@recipient.id, type: 'notification', message: FeedManager.instance.inline_render(@recipient, 'api/v1/notifications/show', @notification))
  end

  def send_email
    NotificationMailer.send(@notification.type, @recipient, @notification).deliver_later
  end

  def email_enabled?
    @recipient.user.settings(:notification_emails).send(@notification.type)
  end
end

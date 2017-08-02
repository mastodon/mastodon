# frozen_string_literal: true

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
    blocked   = @recipient.suspended?                                                                                                # Skip if the recipient account is suspended anyway
    blocked ||= @recipient.id == @notification.from_account.id                                                                       # Skip for interactions with self
    blocked ||= @recipient.domain_blocking?(@notification.from_account.domain) && !@recipient.following?(@notification.from_account) # Skip for domain blocked accounts
    blocked ||= @recipient.blocking?(@notification.from_account)                                                                     # Skip for blocked accounts
    blocked ||= @recipient.muting?(@notification.from_account)                                                                       # Skip for muted accounts
    blocked ||= (@notification.from_account.silenced? && !@recipient.following?(@notification.from_account))                         # Hellban
    blocked ||= (@recipient.user.settings.interactions['must_be_follower']  && !@notification.from_account.following?(@recipient))   # Options
    blocked ||= (@recipient.user.settings.interactions['must_be_following'] && !@recipient.following?(@notification.from_account))   # Options
    blocked ||= conversation_muted?
    blocked ||= send("blocked_#{@notification.type}?")                                                                               # Type-dependent filters
    blocked
  end

  def conversation_muted?
    if @notification.target_status
      @recipient.muting_conversation?(@notification.target_status.conversation)
    else
      false
    end
  end

  def create_notification
    @notification.save!
    return unless @notification.browserable?
    Redis.current.publish("timeline:#{@recipient.id}", Oj.dump(event: :notification, payload: InlineRenderer.render(@notification, @recipient, :notification)))
    send_push_notifications
  end

  def send_push_notifications
    # HACK: Can be caused by quickly unfavouriting a status, since creating
    # a favourite and creating a notification are not wrapped in a transaction.
    return if @notification.activity.nil?

    sessions_with_subscriptions = @recipient.user.session_activations.where.not(web_push_subscription: nil)
    sessions_with_subscriptions_ids = sessions_with_subscriptions.select { |session| session.web_push_subscription.pushable? @notification }.map(&:id)

    WebPushNotificationWorker.push_bulk(sessions_with_subscriptions_ids) do |session_activation_id|
      [session_activation_id, @notification.id]
    end
  end

  def send_email
    NotificationMailer.public_send(@notification.type, @recipient, @notification).deliver_later
  end

  def email_enabled?
    @recipient.user.settings.notification_emails[@notification.type.to_s]
  end
end

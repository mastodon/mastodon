# frozen_string_literal: true

class NotifyService < BaseService
  def call(recipient, activity)
    @recipient    = recipient
    @activity     = activity
    @notification = Notification.new(account: @recipient, activity: @activity)

    return if recipient.user.nil? || blocked?

    create_notification
    send_push_notifications
    send_email if email_enabled?
  rescue ActiveRecord::RecordInvalid
    return
  end

  private

  def blocked_mention?
    FeedManager.instance.filter?(:mentions, @notification.mention.status, @recipient.id)
  end

  def blocked_favourite?
    @recipient.muting?(@notification.from_account)
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
  end

  def send_push_notifications
    @recipient.web_push_subscriptions.each do |web_subscription|
        push_to_subscriber(web_subscription)
      end
  end

  def push_to_subscriber(web_subscription)
    begin
      # TODO: Why is @notification.from_account.hub_url nil?
      name = if @notification.from_account.display_name.empty? then
               "#{@notification.from_account.username}@#{@notification.from_account.hub_url}"
             else
               @notification.from_account.display_name
             end

      # TODO: Move somewhere else
      titles = {
        'Mention' => "#{name} mentioned you",
        'Follow' => "#{name} followed you",
        'FollowRequest' => "#{name} requested to follow you",
        'Favourite' => "#{name} favourited your status",
        'Status' => "#{name} boosted your status",
      }

      title = titles[@notification.activity_type]
      url = case @notification.activity_type
        when 'Mention' then web_url("statuses/#{@notification.target_status.id}")
        when 'Follow' then web_url("accounts/#{@notification.follow.id}")
        when 'FollowRequest' then web_url('follow_requests')
        when 'Favourite' then web_url("statuses/#{@notification.target_status.id}")
        when 'Status' then web_url("statuses/#{@notification.target_status.id}")
      end

      Webpush.payload_send(
        message: JSON.generate(
          title: title,
          options: {
            body: @notification.status.text,
            tag: @notification.id,
            timestamp: @notification.created_at,
            icon: @notification.from_account.avatar_static_url,
            data: {
              url: url,
            }
          }
        ),
        endpoint: web_subscription.endpoint,
        p256dh: web_subscription.key_p256dh,
        auth: web_subscription.key_auth,
        vapid: {
          private_key: Redis.current.get('vapid_private_key'),
          public_key: Redis.current.get('vapid_public_key')
        }
      )
    rescue Webpush::InvalidSubscription
      web_subscription.destroy
    rescue Webpush::ResponseError
      web_subscription.destroy
    end
  end

  def send_email
    NotificationMailer.public_send(@notification.type, @recipient, @notification).deliver_later
  end

  def email_enabled?
    @recipient.user.settings.notification_emails[@notification.type.to_s]
  end
end

# frozen_string_literal: true

class NotifyService < BaseService
  include Redisable

  NON_EMAIL_TYPES = %i(
    admin.report
    admin.sign_up
    update
  ).freeze

  def call(recipient, type, activity)
    @recipient    = recipient
    @activity     = activity
    @notification = Notification.new(account: @recipient, type: type, activity: @activity)

    return if recipient.user.nil? || blocked?

    @notification.save!

    # It's possible the underlying activity has been deleted
    # between the save call and now
    return if @notification.activity.nil?

    push_notification!
    push_to_conversation! if direct_message?
    send_email! if email_needed?
  rescue ActiveRecord::RecordInvalid
    nil
  end

  private

  def blocked_mention?
    FeedManager.instance.filter?(:mentions, @notification.mention.status, @recipient)
  end

  def following_sender?
    return @following_sender if defined?(@following_sender)

    @following_sender = @recipient.following?(@notification.from_account) || @recipient.requested?(@notification.from_account)
  end

  def optional_non_follower?
    @recipient.user.settings['interactions.must_be_follower']  && !@notification.from_account.following?(@recipient)
  end

  def optional_non_following?
    @recipient.user.settings['interactions.must_be_following'] && !following_sender?
  end

  def message?
    @notification.type == :mention
  end

  def direct_message?
    message? && @notification.target_status.direct_visibility?
  end

  # Returns true if the sender has been mentioned by the recipient up the thread
  def response_to_recipient?
    return false if @notification.target_status.in_reply_to_id.nil?

    # Using an SQL CTE to avoid unneeded back-and-forth with SQL server in case of long threads
    !Status.count_by_sql([<<-SQL.squish, id: @notification.target_status.in_reply_to_id, recipient_id: @recipient.id, sender_id: @notification.from_account.id, depth_limit: 100]).zero?
      WITH RECURSIVE ancestors(id, in_reply_to_id, mention_id, path, depth) AS (
          SELECT s.id, s.in_reply_to_id, m.id, ARRAY[s.id], 0
          FROM statuses s
          LEFT JOIN mentions m ON m.silent = FALSE AND m.account_id = :sender_id AND m.status_id = s.id
          WHERE s.id = :id
        UNION ALL
          SELECT s.id, s.in_reply_to_id, m.id, st.path || s.id, st.depth + 1
          FROM ancestors st
          JOIN statuses s ON s.id = st.in_reply_to_id
          LEFT JOIN mentions m ON m.silent = FALSE AND m.account_id = :sender_id AND m.status_id = s.id
          WHERE st.mention_id IS NULL AND NOT s.id = ANY(path) AND st.depth < :depth_limit
      )
      SELECT COUNT(*)
      FROM ancestors st
      JOIN statuses s ON s.id = st.id
      WHERE st.mention_id IS NOT NULL AND s.visibility = 3
    SQL
  end

  def from_staff?
    @notification.from_account.local? && @notification.from_account.user.present? && @notification.from_account.user_role&.overrides?(@recipient.user_role)
  end

  def optional_non_following_and_direct?
    direct_message? &&
      @recipient.user.settings['interactions.must_be_following_dm'] &&
      !following_sender? &&
      !response_to_recipient?
  end

  def hellbanned?
    @notification.from_account.silenced? && !following_sender?
  end

  def from_self?
    @recipient.id == @notification.from_account.id
  end

  def domain_blocking?
    @recipient.domain_blocking?(@notification.from_account.domain) && !following_sender?
  end

  def blocked?
    blocked   = @recipient.suspended?
    blocked ||= from_self? && @notification.type != :poll

    return blocked if message? && from_staff?

    blocked ||= domain_blocking?
    blocked ||= @recipient.blocking?(@notification.from_account)
    blocked ||= @recipient.muting_notifications?(@notification.from_account)
    blocked ||= hellbanned?
    blocked ||= optional_non_follower?
    blocked ||= optional_non_following?
    blocked ||= optional_non_following_and_direct?
    blocked ||= conversation_muted?
    blocked ||= blocked_mention? if @notification.type == :mention
    blocked
  end

  def conversation_muted?
    if @notification.target_status
      @recipient.muting_conversation?(@notification.target_status.conversation)
    else
      false
    end
  end

  def push_notification!
    push_to_streaming_api! if subscribed_to_streaming_api?
    push_to_web_push_subscriptions!
  end

  def push_to_streaming_api!
    redis.publish("timeline:#{@recipient.id}:notifications", Oj.dump(event: :notification, payload: InlineRenderer.render(@notification, @recipient, :notification)))
  end

  def subscribed_to_streaming_api?
    redis.exists?("subscribed:timeline:#{@recipient.id}") || redis.exists?("subscribed:timeline:#{@recipient.id}:notifications")
  end

  def push_to_conversation!
    AccountConversation.add_status(@recipient, @notification.target_status)
  end

  def push_to_web_push_subscriptions!
    ::Web::PushNotificationWorker.push_bulk(web_push_subscriptions.select { |subscription| subscription.pushable?(@notification) }) { |subscription| [subscription.id, @notification.id] }
  end

  def web_push_subscriptions
    @web_push_subscriptions ||= ::Web::PushSubscription.where(user_id: @recipient.user.id).to_a
  end

  def subscribed_to_web_push?
    web_push_subscriptions.any?
  end

  def send_email!
    NotificationMailer.public_send(@notification.type, @recipient, @notification).deliver_later(wait: 2.minutes) if NotificationMailer.respond_to?(@notification.type)
  end

  def email_needed?
    (!recipient_online? || always_send_emails?) && send_email_for_notification_type?
  end

  def recipient_online?
    subscribed_to_streaming_api? || subscribed_to_web_push?
  end

  def always_send_emails?
    @recipient.user.settings.always_send_emails
  end

  def send_email_for_notification_type?
    NON_EMAIL_TYPES.exclude?(@notification.type) && @recipient.user.settings["notification_emails.#{@notification.type}"]
  end
end

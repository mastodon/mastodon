# frozen_string_literal: true

class NotifyService < BaseService
  include Redisable

  NON_EMAIL_TYPES = %i(
    admin.report
    admin.sign_up
    update
    poll
    status
    moderation_warning
    # TODO: this probably warrants an email notification
    severed_relationships
  ).freeze

  class DismissCondition
    def initialize(notification)
      @recipient = notification.account
      @sender = notification.from_account
      @notification = notification
    end

    def dismiss?
      blocked   = @recipient.unavailable?
      blocked ||= from_self? && %i(poll severed_relationships moderation_warning).exclude?(@notification.type)

      return blocked if message? && from_staff?

      blocked ||= domain_blocking?
      blocked ||= @recipient.blocking?(@sender)
      blocked ||= @recipient.muting_notifications?(@sender)
      blocked ||= conversation_muted?
      blocked ||= blocked_mention? if message?
      blocked
    end

    private

    def blocked_mention?
      FeedManager.instance.filter?(:mentions, @notification.target_status, @recipient)
    end

    def message?
      @notification.type == :mention
    end

    def from_staff?
      @sender.local? && @sender.user.present? && @sender.user_role&.overrides?(@recipient.user_role)
    end

    def from_self?
      @recipient.id == @sender.id
    end

    def domain_blocking?
      @recipient.domain_blocking?(@sender.domain) && !following_sender?
    end

    def conversation_muted?
      @notification.target_status && @recipient.muting_conversation?(@notification.target_status.conversation)
    end

    def following_sender?
      @recipient.following?(@sender)
    end
  end

  class FilterCondition
    NEW_ACCOUNT_THRESHOLD = 30.days.freeze

    NEW_FOLLOWER_THRESHOLD = 3.days.freeze

    NON_FILTERABLE_TYPES = %i(
      admin.sign_up
      admin.report
      poll
      update
      account_warning
    ).freeze

    def initialize(notification)
      @notification = notification
      @recipient = notification.account
      @sender = notification.from_account
      @policy = NotificationPolicy.find_or_initialize_by(account: @recipient)
    end

    def filter?
      return false unless Notification::PROPERTIES[@notification.type][:filterable]
      return false if override_for_sender?

      from_limited? ||
        filtered_by_not_following_policy? ||
        filtered_by_not_followers_policy? ||
        filtered_by_new_accounts_policy? ||
        filtered_by_private_mentions_policy?
    end

    private

    def filtered_by_not_following_policy?
      @policy.filter_not_following? && not_following?
    end

    def filtered_by_not_followers_policy?
      @policy.filter_not_followers? && not_follower?
    end

    def filtered_by_new_accounts_policy?
      @policy.filter_new_accounts? && new_account?
    end

    def filtered_by_private_mentions_policy?
      @policy.filter_private_mentions? && not_following? && private_mention_not_in_response?
    end

    def not_following?
      !@recipient.following?(@sender)
    end

    def not_follower?
      follow = Follow.find_by(account: @sender, target_account: @recipient)
      follow.nil? || follow.created_at > NEW_FOLLOWER_THRESHOLD.ago
    end

    def new_account?
      @sender.created_at > NEW_ACCOUNT_THRESHOLD.ago
    end

    def override_for_sender?
      NotificationPermission.exists?(account: @recipient, from_account: @sender)
    end

    def from_limited?
      @sender.silenced? && not_following?
    end

    def private_mention_not_in_response?
      @notification.type == :mention && @notification.target_status.direct_visibility? && !response_to_recipient?
    end

    def response_to_recipient?
      return false if @notification.target_status.in_reply_to_id.nil?

      statuses_that_mention_sender.positive?
    end

    def statuses_that_mention_sender
      # This queries private mentions from the recipient to the sender up in the thread.
      # This allows up to 100 messages that do not match in the thread, allowing conversations
      # involving multiple people.
      Status.count_by_sql([<<-SQL.squish, id: @notification.target_status.in_reply_to_id, recipient_id: @recipient.id, sender_id: @sender.id, depth_limit: 100])
        WITH RECURSIVE ancestors(id, in_reply_to_id, mention_id, path, depth) AS (
            SELECT s.id, s.in_reply_to_id, m.id, ARRAY[s.id], 0
            FROM statuses s
            LEFT JOIN mentions m ON m.silent = FALSE AND m.account_id = :sender_id AND m.status_id = s.id
            WHERE s.id = :id
          UNION ALL
            SELECT s.id, s.in_reply_to_id, m.id, ancestors.path || s.id, ancestors.depth + 1
            FROM ancestors
            JOIN statuses s ON s.id = ancestors.in_reply_to_id
            /* early exit if we already have a mention matching our requirements */
            LEFT JOIN mentions m ON m.silent = FALSE AND m.account_id = :sender_id AND m.status_id = s.id AND s.account_id = :recipient_id
            WHERE ancestors.mention_id IS NULL AND NOT s.id = ANY(path) AND ancestors.depth < :depth_limit
        )
        SELECT COUNT(*)
        FROM ancestors
        JOIN statuses s ON s.id = ancestors.id
        WHERE ancestors.mention_id IS NOT NULL AND s.account_id = :recipient_id AND s.visibility = 3
      SQL
    end
  end

  def call(recipient, type, activity)
    return if recipient.user.nil?

    @recipient    = recipient
    @activity     = activity
    @notification = Notification.new(account: @recipient, type: type, activity: @activity)

    # For certain conditions we don't need to create a notification at all
    return if dismiss?

    @notification.filtered = filter?
    @notification.save!

    # It's possible the underlying activity has been deleted
    # between the save call and now
    return if @notification.activity.nil?

    if @notification.filtered?
      update_notification_request!
    else
      push_notification!
      push_to_conversation! if direct_message?
      send_email! if email_needed?
    end
  rescue ActiveRecord::RecordInvalid
    nil
  end

  private

  def dismiss?
    DismissCondition.new(@notification).dismiss?
  end

  def filter?
    FilterCondition.new(@notification).filter?
  end

  def update_notification_request!
    return unless @notification.type == :mention

    notification_request = NotificationRequest.find_or_initialize_by(account_id: @recipient.id, from_account_id: @notification.from_account_id)
    notification_request.last_status_id = @notification.target_status.id
    notification_request.save
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

  def direct_message?
    @notification.type == :mention && @notification.target_status.direct_visibility?
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
    return unless NotificationMailer.respond_to?(@notification.type)

    NotificationMailer
      .with(recipient: @recipient, notification: @notification)
      .public_send(@notification.type)
      .deliver_later(wait: 2.minutes)
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

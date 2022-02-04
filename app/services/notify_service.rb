# frozen_string_literal: true

class NotifyService < BaseService
  def call(recipient, type, activity)
    @recipient    = recipient
    @activity     = activity
    @notification = Notification.new(account: @recipient, type: type, activity: @activity)

    return if recipient.user.nil? || blocked?

    create_notification!
    push_notification!
    push_to_conversation! if direct_message?
    send_email! if email_enabled?
  rescue ActiveRecord::RecordInvalid
    nil
  end

  private

  def blocked_mention?
    FeedManager.instance.filter?(:mentions, @notification.mention.status, @recipient)
  end

  def blocked_status?
    false
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

  def blocked_poll?
    false
  end

  def following_sender?
    return @following_sender if defined?(@following_sender)
    @following_sender = @recipient.following?(@notification.from_account) || @recipient.requested?(@notification.from_account)
  end

  def optional_non_follower?
    @recipient.user.settings.interactions['must_be_follower']  && !@notification.from_account.following?(@recipient)
  end

  def optional_non_following?
    @recipient.user.settings.interactions['must_be_following'] && !following_sender?
  end

  def message?
    @notification.type == :mention
  end

  def direct_message?
    message? && @notification.target_status.direct_visibility?
  end

  # Returns true if the sender has been mentionned by the recipient up the thread
  def response_to_recipient?
    return false if @notification.target_status.in_reply_to_id.nil?

    # Using an SQL CTE to avoid unneeded back-and-forth with SQL server in case of long threads
    !Status.count_by_sql([<<-SQL.squish, id: @notification.target_status.in_reply_to_id, recipient_id: @recipient.id, sender_id: @notification.from_account.id]).zero?
      WITH RECURSIVE ancestors(id, in_reply_to_id, replying_to_sender, path) AS (
          SELECT
            s.id,
            s.in_reply_to_id,
            (CASE
              WHEN s.account_id = :recipient_id THEN
                EXISTS (
                  SELECT *
                  FROM mentions m
                  WHERE m.silent = FALSE AND m.account_id = :sender_id AND m.status_id = s.id
                )
              ELSE
                FALSE
             END),
            ARRAY[s.id]
          FROM statuses s
          WHERE s.id = :id
        UNION ALL
          SELECT
            s.id,
            s.in_reply_to_id,
            (CASE
              WHEN s.account_id = :recipient_id THEN
                EXISTS (
                  SELECT *
                  FROM mentions m
                  WHERE m.silent = FALSE AND m.account_id = :sender_id AND m.status_id = s.id
                )
              ELSE
                FALSE
             END),
            st.path || s.id
          FROM ancestors st
          JOIN statuses s ON s.id = st.in_reply_to_id
          WHERE st.replying_to_sender IS FALSE AND NOT s.id = ANY(path)
      )
      SELECT COUNT(*)
      FROM ancestors st
      JOIN statuses s ON s.id = st.id
      WHERE st.replying_to_sender IS TRUE AND s.visibility = 3
    SQL
  end

  def from_staff?
    @notification.from_account.local? && @notification.from_account.user.present? && @notification.from_account.user.staff?
  end

  def optional_non_following_and_direct?
    direct_message? &&
      @recipient.user.settings.interactions['must_be_following_dm'] &&
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
    blocked   = @recipient.suspended?                            # Skip if the recipient account is suspended anyway
    blocked ||= from_self? && @notification.type != :poll        # Skip for interactions with self

    return blocked if message? && from_staff?

    blocked ||= domain_blocking?                                 # Skip for domain blocked accounts
    blocked ||= @recipient.blocking?(@notification.from_account) # Skip for blocked accounts
    blocked ||= @recipient.muting_notifications?(@notification.from_account)
    blocked ||= hellbanned?                                      # Hellban
    blocked ||= optional_non_follower?                           # Options
    blocked ||= optional_non_following?                          # Options
    blocked ||= optional_non_following_and_direct?               # Options
    blocked ||= conversation_muted?
    blocked ||= send("blocked_#{@notification.type}?")           # Type-dependent filters
    blocked
  end

  def conversation_muted?
    if @notification.target_status
      @recipient.muting_conversation?(@notification.target_status.conversation)
    else
      false
    end
  end

  def create_notification!
    @notification.save!
  end

  def push_notification!
    return if @notification.activity.nil?

    Redis.current.publish("timeline:#{@recipient.id}", Oj.dump(event: :notification, payload: InlineRenderer.render(@notification, @recipient, :notification)))
    send_push_notifications!
  end

  def push_to_conversation!
    return if @notification.activity.nil?
    AccountConversation.add_status(@recipient, @notification.target_status)
  end

  def send_push_notifications!
    subscriptions_ids = ::Web::PushSubscription.where(user_id: @recipient.user.id)
                                               .select { |subscription| subscription.pushable?(@notification) }
                                               .map(&:id)

    ::Web::PushNotificationWorker.push_bulk(subscriptions_ids) do |subscription_id|
      [subscription_id, @notification.id]
    end
  end

  def send_email!
    return if @notification.activity.nil?
    NotificationMailer.public_send(@notification.type, @recipient, @notification).deliver_later(wait: 2.minutes)
  end

  def email_enabled?
    @recipient.user.settings.notification_emails[@notification.type.to_s]
  end
end

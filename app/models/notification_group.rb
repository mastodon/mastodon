# frozen_string_literal: true

class NotificationGroup < ActiveModelSerializers::Model
  attributes :group_key, :sample_accounts, :notifications_count, :notification, :most_recent_notification_id

  # Try to keep this consistent with `app/javascript/mastodon/models/notification_group.ts`
  SAMPLE_ACCOUNTS_SIZE = 8

  def self.from_notification(notification, max_id: nil)
    if notification.group_key.present?
      # TODO: caching, and, if caching, preloading
      scope = notification.account.notifications.where(group_key: notification.group_key)
      scope = scope.where(id: ..max_id) if max_id.present?

      # Ideally, we would not load accounts for each notification group
      most_recent_notifications = scope.order(id: :desc).includes(:from_account).take(SAMPLE_ACCOUNTS_SIZE)
      most_recent_id = most_recent_notifications.first.id
      sample_accounts = most_recent_notifications.map(&:from_account)
      notifications_count = scope.count
    else
      most_recent_id = notification.id
      sample_accounts = [notification.from_account]
      notifications_count = 1
    end

    NotificationGroup.new(
      notification: notification,
      group_key: notification.group_key || "ungrouped-#{notification.id}",
      sample_accounts: sample_accounts,
      notifications_count: notifications_count,
      most_recent_notification_id: most_recent_id
    )
  end

  delegate :type,
           :target_status,
           :report,
           :account_relationship_severance_event,
           :account_warning,
           to: :notification, prefix: false
end

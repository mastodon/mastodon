# frozen_string_literal: true

class NotificationGroup < ActiveModelSerializers::Model
  attributes :group_key, :sample_accounts, :notifications_count, :notification

  def self.from_notification(notification)
    if notification.group_key.present?
      # TODO: caching and preloading
      sample_accounts = notification.account.notifications.where(group_key: notification.group_key).order(id: :desc).limit(3).map(&:from_account)
      notifications_count = notification.account.notifications.where(group_key: notification.group_key).count
    else
      sample_accounts = [notification.from_account]
      notifications_count = 1
    end

    NotificationGroup.new(
      notification: notification,
      group_key: notification.group_key || "ungrouped-#{notification.id}",
      sample_accounts: sample_accounts,
      notifications_count: notifications_count
    )
  end

  delegate :type,
           :target_status,
           :report,
           :account_relationship_severance_event,
           to: :notification, prefix: false
end

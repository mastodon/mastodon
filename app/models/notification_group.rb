# frozen_string_literal: true

class NotificationGroup < ActiveModelSerializers::Model
  attributes :group_key, :sample_accounts, :notifications_count, :notification, :most_recent_notification_id

  # Try to keep this consistent with `app/javascript/mastodon/models/notification_group.ts`
  SAMPLE_ACCOUNTS_SIZE = 8

  def self.from_notifications(notifications, max_id: nil, grouped_types: nil)
    return [] if notifications.empty?

    grouped_types = grouped_types.presence&.map(&:to_sym) || Notification::GROUPABLE_NOTIFICATION_TYPES

    grouped_notifications = notifications.filter { |notification| notification.group_key.present? && grouped_types.include?(notification.type) }
    group_keys = grouped_notifications.pluck(:group_key)

    groups_data = load_groups_data(notifications.first.account_id, group_keys, max_id: max_id)
    accounts_map = Account.where(id: groups_data.values.pluck(1).flatten).index_by(&:id)

    notifications.map do |notification|
      if notification.group_key.present? && grouped_types.include?(notification.type)
        most_recent_notification_id, sample_account_ids, count = groups_data[notification.group_key]
        NotificationGroup.new(
          notification: notification,
          group_key: notification.group_key,
          sample_accounts: sample_account_ids.map { |id| accounts_map[id] },
          notifications_count: count,
          most_recent_notification_id: most_recent_notification_id
        )
      else
        NotificationGroup.new(
          notification: notification,
          group_key: "ungrouped-#{notification.id}",
          sample_accounts: [notification.from_account],
          notifications_count: 1,
          most_recent_notification_id: notification.id
        )
      end
    end
  end

  delegate :type,
           :target_status,
           :report,
           :account_relationship_severance_event,
           :account_warning,
           to: :notification, prefix: false

  class << self
    private

    def load_groups_data(account_id, group_keys, max_id: nil)
      return {} if group_keys.empty?

      if max_id.present?
        binds = [
          account_id,
          max_id,
          SAMPLE_ACCOUNTS_SIZE,
        ]
        binds.concat(group_keys)

        ActiveRecord::Base.connection.select_all(<<~SQL.squish, 'grouped_notifications', binds).cast_values.to_h { |k, *values| [k, values] }
          SELECT
            groups.group_key,
            (SELECT id FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key AND id <= $2 ORDER BY id DESC LIMIT 1),
            array(SELECT from_account_id FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key AND id <= $2 ORDER BY id DESC LIMIT $3),
            (SELECT count(*) FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key AND id <= $2) AS notifications_count
          FROM
            (VALUES #{Array.new(group_keys.size) { |i| "($#{i + 4})" }.join(', ')}) AS groups(group_key);
        SQL
      else
        binds = [
          account_id,
          SAMPLE_ACCOUNTS_SIZE,
        ]
        binds.concat(group_keys)

        ActiveRecord::Base.connection.select_all(<<~SQL.squish, 'grouped_notifications', binds).cast_values.to_h { |k, *values| [k, values] }
          SELECT
            groups.group_key,
            (SELECT id FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key ORDER BY id DESC LIMIT 1),
            array(SELECT from_account_id FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key ORDER BY id DESC LIMIT $2),
            (SELECT count(*) FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key) AS notifications_count
          FROM
            (VALUES #{Array.new(group_keys.size) { |i| "($#{i + 3})" }.join(', ')}) AS groups(group_key);
        SQL
      end
    end
  end
end

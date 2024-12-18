# frozen_string_literal: true

class NotificationGroup < ActiveModelSerializers::Model
  attributes :group_key, :sample_accounts, :notifications_count, :notification, :most_recent_notification_id, :pagination_data

  # Try to keep this consistent with `app/javascript/mastodon/models/notification_group.ts`
  SAMPLE_ACCOUNTS_SIZE = 8

  def self.from_notifications(notifications, pagination_range: nil, grouped_types: nil)
    return [] if notifications.empty?

    grouped_types = grouped_types.presence&.map(&:to_sym) || Notification::GROUPABLE_NOTIFICATION_TYPES

    grouped_notifications = notifications.filter { |notification| notification.group_key.present? && grouped_types.include?(notification.type) }
    group_keys = grouped_notifications.pluck(:group_key)

    groups_data = load_groups_data(notifications.first.account_id, group_keys, pagination_range: pagination_range)
    accounts_map = Account.where(id: groups_data.values.pluck(1).flatten).index_by(&:id)

    notifications.map do |notification|
      if notification.group_key.present? && grouped_types.include?(notification.type)
        most_recent_notification_id, sample_account_ids, count, *raw_pagination_data = groups_data[notification.group_key]

        pagination_data = raw_pagination_data.empty? ? nil : { min_id: raw_pagination_data[0], latest_notification_at: raw_pagination_data[1] }

        NotificationGroup.new(
          notification: notification,
          group_key: notification.group_key,
          sample_accounts: sample_account_ids.map { |id| accounts_map[id] },
          notifications_count: count,
          most_recent_notification_id: most_recent_notification_id,
          pagination_data: pagination_data
        )
      else
        pagination_data = pagination_range.blank? ? nil : { min_id: notification.id, latest_notification_at: notification.created_at }

        NotificationGroup.new(
          notification: notification,
          group_key: "ungrouped-#{notification.id}",
          sample_accounts: [notification.from_account],
          notifications_count: 1,
          most_recent_notification_id: notification.id,
          pagination_data: pagination_data
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

    def load_groups_data(account_id, group_keys, pagination_range: nil)
      return {} if group_keys.empty?

      if pagination_range.present?
        binds = [
          account_id,
          SAMPLE_ACCOUNTS_SIZE,
          pagination_range.begin,
          pagination_range.end,
          ActiveRecord::Relation::QueryAttribute.new('group_keys', group_keys, ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(ActiveModel::Type::String.new)),
        ]

        ActiveRecord::Base.connection.select_all(<<~SQL.squish, 'grouped_notifications', binds).cast_values.to_h { |k, *values| [k, values] }
          SELECT
            groups.group_key,
            (SELECT id FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key AND id <= $4 ORDER BY id DESC LIMIT 1),
            array(SELECT from_account_id FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key AND id <= $4 ORDER BY id DESC LIMIT $2),
            (SELECT count(*) FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key AND id <= $4) AS notifications_count,
            (SELECT id FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key AND id >= $3 ORDER BY id ASC LIMIT 1) AS min_id,
            (SELECT created_at FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key AND id <= $4 ORDER BY id DESC LIMIT 1)
          FROM
            unnest($5::text[]) AS groups(group_key);
        SQL
      else
        binds = [
          account_id,
          SAMPLE_ACCOUNTS_SIZE,
          ActiveRecord::Relation::QueryAttribute.new('group_keys', group_keys, ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(ActiveModel::Type::String.new)),
        ]

        ActiveRecord::Base.connection.select_all(<<~SQL.squish, 'grouped_notifications', binds).cast_values.to_h { |k, *values| [k, values] }
          SELECT
            groups.group_key,
            (SELECT id FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key ORDER BY id DESC LIMIT 1),
            array(SELECT from_account_id FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key ORDER BY id DESC LIMIT $2),
            (SELECT count(*) FROM notifications WHERE notifications.account_id = $1 AND notifications.group_key = groups.group_key) AS notifications_count
          FROM
            unnest($3::text[]) AS groups(group_key);
        SQL
      end
    end
  end
end

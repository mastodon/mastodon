# frozen_string_literal: true

class GroupedNotificationsPresenter < ActiveModelSerializers::Model
  def initialize(grouped_notifications)
    super()

    @grouped_notifications = grouped_notifications
  end

  def notification_groups
    @grouped_notifications
  end

  def statuses
    @grouped_notifications.filter_map(&:target_status).uniq(&:id)
  end

  def accounts
    @grouped_notifications.flat_map(&:sample_accounts).uniq(&:id)
  end
end

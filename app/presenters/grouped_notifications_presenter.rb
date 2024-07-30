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
    @grouped_notifications.filter_map(&:target_status)
  end

  def accounts
    @grouped_notifications.flat_map do |group|
      accounts = group.sample_accounts.dup

      case group.type
      when :favourite, :reblog, :status, :mention, :poll, :update
        accounts << group.target_status&.account
      when :'admin.report'
        accounts << group.report&.target_account
      when :moderation_warning
        accounts << group.account_warning&.target_account
      end

      accounts.compact
    end.uniq(&:id)
  end
end

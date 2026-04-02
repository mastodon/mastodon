# frozen_string_literal: true

class LocalNotificationWorker
  include Sidekiq::Worker

  def perform(receiver_account_id, activity_id, activity_class_name, type = nil, options = {})
    receiver = Account.find(receiver_account_id)
    activity = activity_class_name.constantize.find(activity_id)

    # For most notification types, only one notification should exist, and the older one is
    # preferred. For updates, such as when a status is edited, the new notification
    # should replace the previous ones.
    if type == 'update'
      Notification.where(account: receiver, activity: activity, type: 'update').in_batches.delete_all
    elsif type == 'quoted_update'
      Notification.where(account: receiver, activity: activity, type: 'quoted_update').in_batches.delete_all
    elsif Notification.where(account: receiver, activity: activity, type: type).any?
      return
    end

    NotifyService.new.call(receiver, type || activity_class_name.underscore, activity, **options.symbolize_keys)
  rescue ActiveRecord::RecordNotFound
    true
  end
end

# frozen_string_literal: true

class LocalNotificationWorker
  include Sidekiq::Worker

  def perform(receiver_account_id, activity_id = nil, activity_class_name = nil, type = nil)
    if activity_id.nil? && activity_class_name.nil?
      activity = Mention.find(receiver_account_id)
      receiver = activity.account
    else
      receiver = Account.find(receiver_account_id)
      activity = activity_class_name.constantize.find(activity_id)
    end

    return if Notification.where(account: receiver, activity: activity).any?

    NotifyService.new.call(receiver, type || activity_class_name.underscore, activity)
  rescue ActiveRecord::RecordNotFound
    true
  end
end

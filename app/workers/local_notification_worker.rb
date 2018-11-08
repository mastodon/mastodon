# frozen_string_literal: true

class LocalNotificationWorker
  include Sidekiq::Worker

  def perform(receiver_account_id, activity_id = nil, activity_class_name = nil)
    if activity_id.nil? && activity_class_name.nil?
      activity = Mention.find(receiver_account_id)
      receiver = activity.account
    else
      receiver = Account.find(receiver_account_id)
      activity = activity_class_name.constantize.find(activity_id)
    end

    NotifyService.new.call(receiver, activity)
  rescue ActiveRecord::RecordNotFound
    true
  end
end

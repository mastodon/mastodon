# frozen_string_literal: true

class Admin::DistributeAnnouncementNotificationWorker
  include Sidekiq::Worker

  def perform(announcement_id)
    announcement = Announcement.find(announcement_id)

    announcement.scope_for_notification.find_each do |user|
      UserMailer.announcement_published(user, announcement).deliver_later!
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end

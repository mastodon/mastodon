# frozen_string_literal: true

class Admin::Announcements::DistributionsController < Admin::BaseController
  before_action :set_announcement

  def create
    authorize @announcement, :distribute?
    @announcement.touch(:notification_sent_at)
    Admin::DistributeAnnouncementNotificationWorker.perform_async(@announcement.id)
    redirect_to admin_announcements_path
  end

  private

  def set_announcement
    @announcement = Announcement.find(params[:announcement_id])
  end
end

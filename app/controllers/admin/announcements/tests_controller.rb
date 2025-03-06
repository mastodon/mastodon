# frozen_string_literal: true

class Admin::Announcements::TestsController < Admin::BaseController
  before_action :set_announcement

  def create
    authorize @announcement, :distribute?
    UserMailer.announcement_published(current_user, @announcement).deliver_later!
    redirect_to admin_announcements_path
  end

  private

  def set_announcement
    @announcement = Announcement.find(params[:announcement_id])
  end
end

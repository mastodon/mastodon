# frozen_string_literal: true

class Admin::Announcements::PreviewsController < Admin::BaseController
  before_action :set_announcement

  def show
    authorize @announcement, :distribute?
    @user_count = @announcement.scope_for_notification.count
  end

  private

  def set_announcement
    @announcement = Announcement.find(params[:announcement_id])
  end
end

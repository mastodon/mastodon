# frozen_string_literal: true

class Api::V1::AnnouncementsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, only: :dismiss
  before_action :require_user!
  before_action :set_announcements, only: :index
  before_action :set_announcement, except: :index

  def index
    render json: @announcements, each_serializer: REST::AnnouncementSerializer
  end

  def dismiss
    AnnouncementMute.create!(account: current_account, announcement: @announcement)
    render_empty
  end

  private

  def set_announcements
    @announcements = begin
      scope = Announcement.published

      scope.merge!(Announcement.without_muted(current_account)) unless truthy_param?(:with_dismissed)

      scope.chronological
    end
  end

  def set_announcement
    @announcement = Announcement.published.find(params[:id])
  end
end

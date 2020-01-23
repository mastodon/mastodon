# frozen_string_literal: true

class Admin::AnnouncementsController < Admin::BaseController
  before_action :set_announcements, only: :index
  before_action :set_announcement, except: [:index, :new, :create]

  def index
    authorize :announcement, :index?
  end

  def new
    authorize :announcement, :create?

    @announcement = Announcement.new
  end

  def create
    authorize :announcement, :create?

    @announcement = Announcement.new(resource_params)

    if @announcement.save
      log_action :create, @announcement
      redirect_to admin_announcements_path
    else
      render :new
    end
  end

  def edit
    authorize :announcement, :update?
  end

  def update
    authorize :announcement, :update?

    if @announcement.update(resource_params)
      log_action :update, @announcement
      redirect_to admin_announcements_path
    else
      render :edit
    end
  end

  def destroy
    authorize :announcement, :destroy?
    @announcement.destroy!
    log_action :destroy, @announcement
    redirect_to admin_announcements_path
  end

  private

  def set_announcements
    @announcements = AnnouncementFilter.new(filter_params).results.page(params[:page])
  end

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  def filter_params
    params.slice(*AnnouncementFilter::KEYS).permit(*AnnouncementFilter::KEYS)
  end

  def resource_params
    params.require(:announcement).permit(:text, :scheduled_at, :starts_at, :ends_at, :all_day)
  end
end

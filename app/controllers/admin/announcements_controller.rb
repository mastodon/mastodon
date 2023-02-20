# frozen_string_literal: true

class Admin::AnnouncementsController < Admin::BaseController
  before_action :set_announcements, only: :index
  before_action :set_announcement, except: %i(index new create)

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
      PublishScheduledAnnouncementWorker.perform_async(@announcement.id) if @announcement.published?
      log_action :create, @announcement
      redirect_to admin_announcements_path, notice: @announcement.published? ? I18n.t('admin.announcements.published_msg') : I18n.t('admin.announcements.scheduled_msg')
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
      PublishScheduledAnnouncementWorker.perform_async(@announcement.id) if @announcement.published?
      log_action :update, @announcement
      redirect_to admin_announcements_path, notice: I18n.t('admin.announcements.updated_msg')
    else
      render :edit
    end
  end

  def publish
    authorize :announcement, :update?
    @announcement.publish!
    PublishScheduledAnnouncementWorker.perform_async(@announcement.id)
    log_action :update, @announcement
    redirect_to admin_announcements_path, notice: I18n.t('admin.announcements.published_msg')
  end

  def unpublish
    authorize :announcement, :update?
    @announcement.unpublish!
    UnpublishAnnouncementWorker.perform_async(@announcement.id)
    log_action :update, @announcement
    redirect_to admin_announcements_path, notice: I18n.t('admin.announcements.unpublished_msg')
  end

  def destroy
    authorize :announcement, :destroy?
    @announcement.destroy!
    UnpublishAnnouncementWorker.perform_async(@announcement.id) if @announcement.published?
    log_action :destroy, @announcement
    redirect_to admin_announcements_path, notice: I18n.t('admin.announcements.destroyed_msg')
  end

  private

  def set_announcements
    @announcements = AnnouncementFilter.new(filter_params).results.reverse_chronological.page(params[:page])
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

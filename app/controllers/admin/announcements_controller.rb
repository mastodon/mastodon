# frozen_string_literal: true

class Admin::AnnouncementsController < Admin::BaseController
  before_action :set_announcements, only: [:index]
  before_action :set_announcement, only: [:edit, :update, :destroy]
  after_action :publish_updates, only: [:create, :update, :destroy]

  def index
  end

  def new
    @announcement = Announcement.new
    fill_links!
  end

  def edit
    fill_links!
  end

  def create
    @announcement = Announcement.new(announcement_params)
    if @announcement.save
      redirect_to :admin_announcements
    else
      fill_links!
      render :new
    end
  end

  def update
    if @announcement.update(announcement_params)
      redirect_to :admin_announcements
    else
      fill_links!
      render :edit
    end
  end

  def destroy
    @announcement.destroy
    redirect_to admin_announcements_path
  end

  private

  def set_announcements
    @announcements = Announcement.all
  end

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  def announcement_params
    params.require(:announcement).permit(:body, :order, links_attributes: [:id, :text, :url]).tap do |x|
      x[:links_attributes].each do |_n, link|
        link[:_destroy] = 1 if link[:id].present? && link[:url].blank? && link[:text].blank?
      end
    end
  end

  def fill_links!
    @announcement.links << (3 - @announcement.links.length).times.map { AnnouncementLink.new }
  end

  def publish_updates
    AnnouncementPublishWorker.perform_async
  end
end

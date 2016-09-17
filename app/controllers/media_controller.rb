class MediaController < ApplicationController
  before_action :set_media_attachment

  def show
    redirect TagManager.instance.url_for(@media_attachment.status)
  end

  private

  def set_media_attachment
    @media_attachment = MediaAttachment.where.not(status_id: nil).find(params[:id])
  end
end

# frozen_string_literal: true

class MediaController < ApplicationController
  before_action :set_media_attachment

  def show
    redirect_to @media_attachment.file.url(:original)
  end

  private

  def set_media_attachment
    @media_attachment = MediaAttachment.where.not(status_id: nil).find(params[:id])
  end
end

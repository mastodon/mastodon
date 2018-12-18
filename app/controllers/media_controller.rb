# frozen_string_literal: true

class MediaController < ApplicationController
  include Authorization

  before_action :set_media_attachment
  before_action :verify_permitted_status!

  content_security_policy only: :player do |p|
    p.frame_ancestors(false)
  end

  def show
    redirect_to @media_attachment.file.url(:original)
  end

  def player
    @body_classes = 'player'
    response.headers['X-Frame-Options'] = 'ALLOWALL'
    raise ActiveRecord::RecordNotFound unless @media_attachment.video? || @media_attachment.gifv?
  end

  private

  def set_media_attachment
    @media_attachment = MediaAttachment.attached.find_by!(shortcode: params[:id] || params[:medium_id])
  end

  def verify_permitted_status!
    authorize @media_attachment.status, :show?
  rescue Mastodon::NotPermittedError
    # Reraise in order to get a 404 instead of a 403 error code
    raise ActiveRecord::RecordNotFound
  end
end

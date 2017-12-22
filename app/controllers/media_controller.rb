# frozen_string_literal: true

class MediaController < ApplicationController
  include Authorization

  before_action :verify_permitted_status

  def show
    if params[:thumb].present?
      redirect_to media_attachment.file.url(:small)
    else
      redirect_to media_attachment.file.url(:original)
    end
  end

  private

  def media_attachment
    MediaAttachment.attached.find_by!(shortcode: params[:id])
  end

  def verify_permitted_status
    authorize media_attachment.status, :show?
  rescue Mastodon::NotPermittedError
    # Reraise in order to get a 404 instead of a 403 error code
    raise ActiveRecord::RecordNotFound
  end
end

# frozen_string_literal: true

class MediaController < ApplicationController
  before_action :verify_permitted_status

  def show
    redirect_to media_attachment.file.url(:original)
  end

  private

  def media_attachment
    MediaAttachment.attached.find_by!(shortcode: params[:id])
  end

  def verify_permitted_status
    raise ActiveRecord::RecordNotFound unless media_attachment.status.permitted?(current_account)
  end
end

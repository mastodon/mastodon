# frozen_string_literal: true

class Api::V1::MediaController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:media' }
  before_action :require_user!
  before_action :set_media_attachment, except: [:create]
  before_action :check_processing, except: [:create]

  def create
    @media_attachment = current_account.media_attachments.create!(media_attachment_params)
    render json: @media_attachment, serializer: REST::MediaAttachmentSerializer
  rescue Paperclip::Errors::NotIdentifiedByImageMagickError
    render json: file_type_error, status: 422
  rescue Paperclip::Error
    render json: processing_error, status: 500
  end

  def show
    render json: @media_attachment, serializer: REST::MediaAttachmentSerializer, status: status_code_for_media_attachment
  end

  def update
    @media_attachment.update!(updateable_media_attachment_params)

    # If the media attachment being updated is attached to a published
    # status, then the changes need to be recorded and distributed along
    # with the status, but it may be that the status is going to be updated
    # along with the media attachment, so we need to debounce
    if @media_attachment.status_id.present? && @media_attachment.significantly_changed?
      PublishMediaAttachmentUpdateWorker.perform_in(5.minutes, @media_attachment.id, @media_attachment.updated_at)
    end

    render json: @media_attachment, serializer: REST::MediaAttachmentSerializer, status: status_code_for_media_attachment
  end

  private

  def status_code_for_media_attachment
    @media_attachment.not_processed? ? 206 : 200
  end

  def set_media_attachment
    @media_attachment = current_account.media_attachments.find(params[:id])
  end

  def check_processing
    render json: processing_error, status: 422 if @media_attachment.processing_failed?
  end

  def media_attachment_params
    params.permit(:file, :thumbnail, :description, :focus)
  end

  def updateable_media_attachment_params
    params.permit(:thumbnail, :description, :focus)
  end

  def file_type_error
    { error: 'File type of uploaded media could not be verified' }
  end

  def processing_error
    { error: 'Error processing thumbnail for uploaded media' }
  end
end

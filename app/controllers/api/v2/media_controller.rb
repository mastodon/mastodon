# frozen_string_literal: true

class Api::V2::MediaController < Api::V1::MediaController
  def create
    @media_attachment = current_account.media_attachments.create!({ delay_processing: true }.merge(media_attachment_params))
    render json: @media_attachment, serializer: REST::MediaAttachmentSerializer, status: @media_attachment.not_processed? ? 202 : 200
  rescue Paperclip::Errors::NotIdentifiedByImageMagickError
    render json: file_type_error, status: 422
  rescue Paperclip::Error => e
    Rails.logger.error "#{e.class}: #{e.message}"
    render json: processing_error, status: 500
  end
end

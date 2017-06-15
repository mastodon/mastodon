# frozen_string_literal: true

class Api::V1::MediaController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write }
  before_action :require_user!

  include ObfuscateFilename
  obfuscate_filename :file

  respond_to :json

  def create
    @media = current_account.media_attachments.create!(file: media_params[:file])
  rescue Paperclip::Errors::NotIdentifiedByImageMagickError
    render json: file_type_error, status: 422
  rescue Paperclip::Error
    render json: processing_error, status: 500
  end

  private

  def media_params
    params.permit(:file)
  end

  def file_type_error
    { error: 'File type of uploaded media could not be verified' }
  end

  def processing_error
    { error: 'Error processing thumbnail for uploaded media' }
  end
end

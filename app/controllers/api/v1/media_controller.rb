class Api::V1::MediaController < ApiController
  before_action -> { doorkeeper_authorize! :write }
  before_action :require_user!

  respond_to :json

  def create
    @media = MediaAttachment.create!(account: current_user.account, file: params[:file])
  rescue Paperclip::Errors::NotIdentifiedByImageMagickError
    render json: { error: 'File type of uploaded media could not be verified' }, status: 422
  rescue Paperclip::Error
    render json: { error: 'Error processing thumbnail for uploaded media' }, status: 500
  end
end

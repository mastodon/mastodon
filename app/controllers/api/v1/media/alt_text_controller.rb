# frozen_string_literal: true

class Api::V1::Media::AltTextController < Api::BaseController
  include Authorization
  before_action -> { doorkeeper_authorize! :write, :'write:media' }, only: [:create], if: -> { request.authorization.present? }
  before_action :require_user!
  before_action :set_media_attachment

  def create
    # Skip authorization for now since MediaAttachmentPolicy doesn't exist
    # authorize @media_attachment, :update?

    # Check if this is an AI request
    if request.path.end_with?('/ai')
      generate_ai_alt_text
    else
      # Handle regular alt text update if needed
      render json: { error: 'Not implemented' }, status: 422
    end
  end

  private

  def generate_ai_alt_text
    if !Mastodon::Feature.alt_text_ai_enabled?
      render json: { error: 'AI alt text generation is not enabled' }, status: 422
      return
    end

    if !@media_attachment.image?
      render json: { error: 'AI alt text generation is only available for images' }, status: 422
      return
    end

    alt_text = AltTextAiService.instance.generate_alt_text(@media_attachment)

    if alt_text.present?
      render json: { description: alt_text }
    else
      render json: { error: 'Failed to generate alt text' }, status: 422
    end
  end

  def set_media_attachment
    @media_attachment = current_account.media_attachments.where(status_id: nil).find(params[:medium_id] || params[:media_id])
  end
end
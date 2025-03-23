# frozen_string_literal: true

class Api::V1::Media::AltTextController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:media' }
  before_action :require_user!
  before_action :set_media_attachment

  def create
    authorize @media_attachment, :update?

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

  private

  def set_media_attachment
    @media_attachment = current_account.media_attachments.where(status_id: nil).find(params[:media_id])
  end
end
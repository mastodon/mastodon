# frozen_string_literal: true

class Api::V1::CustomEmojisController < Api::BaseController
  respond_to :json

  def index
    render json: CustomEmoji.local.where(disabled: false), each_serializer: REST::CustomEmojiSerializer
  end
end

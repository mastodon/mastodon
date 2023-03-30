# frozen_string_literal: true

class Api::V1::CustomEmojisController < Api::BaseController
  skip_before_action :set_cache_headers

  def index
    expires_in 3.minutes, public: true
    render json: CustomEmoji.listed.includes(:category), each_serializer: REST::CustomEmojiSerializer
  end
end

# frozen_string_literal: true

class Api::V1::CustomEmojisController < Api::BaseController
  before_action :set_tags
  
  def index
    @tags = set_tags
    # must cache in Nginx side, or should use original render_with_cache method
    render json: @tags, each_serializer: REST::CustomEmojiSerializer
  end

  private

  def custom_emojis_params
    params.slice(:range).permit(:range)
  end

  def set_tags
    @range = custom_emojis_params[:range]
    case @range
      when 'all'
        CustomEmoji.fullist.includes(:category)
      when 'unlisted'
        CustomEmoji.unlisted.includes(:category)
      else
        CustomEmoji.listed.includes(:category)
      end
  end
end

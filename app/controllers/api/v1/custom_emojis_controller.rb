# frozen_string_literal: true

class Api::V1::CustomEmojisController < Api::BaseController
  respond_to :json

  skip_before_action :set_cache_headers

  def index
    expires_in 3.minutes, public: true
    render_with_cache(each_serializer: REST::CustomEmojiSerializer) { CustomEmoji.local.where(disabled: false).includes(:category) }
  end
end

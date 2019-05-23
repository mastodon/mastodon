# frozen_string_literal: true

class Api::V1::CustomEmojisController < Api::BaseController
  respond_to :json

  skip_before_action :set_cache_headers

  def index
    render_cached_json('api:v1:custom_emojis', expires_in: 1.minute) do
      ActiveModelSerializers::SerializableResource.new(CustomEmoji.local.where(disabled: false), each_serializer: REST::CustomEmojiSerializer)
    end
  end
end

# frozen_string_literal: true

class Api::V1::CustomEmojisController < Api::BaseController
  skip_before_action :set_cache_headers

  def index
    expires_in 3.minutes, public: true
    emojis = if truthy_param?(:include_unlisted)
               CustomEmoji.visible.includes(:category)
             else
               CustomEmoji.listed.includes(:category)
             end
    render_with_cache(each_serializer: REST::CustomEmojiSerializer) { emojis }
  end
end

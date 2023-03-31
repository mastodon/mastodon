# frozen_string_literal: true

class Api::V1::CustomEmojisController < Api::BaseController
  vary_by ''

  def index
    cache_even_if_authenticated!
    render_with_cache(each_serializer: REST::CustomEmojiSerializer) { CustomEmoji.listed.includes(:category) }
  end
end

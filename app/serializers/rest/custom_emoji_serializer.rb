# frozen_string_literal: true

class REST::CustomEmojiSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :shortcode, :url

  def url
    full_asset_url(object.custom_emoji_icon.image.url)
  end
end

# frozen_string_literal: true

class REST::CustomEmojiSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :shortcode, :url

  def url
    full_asset_url(object.image.url)
  end
end

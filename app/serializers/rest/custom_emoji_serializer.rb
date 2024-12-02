# frozen_string_literal: true

class REST::CustomEmojiSerializer < ActiveModel::Serializer
  include RoutingHelper

  # Please update `app/javascript/mastodon/api_types/custom_emoji.ts` when making changes to the attributes

  attributes :shortcode, :url, :static_url, :visible_in_picker

  attribute :category, if: :category_loaded?

  def url
    full_asset_url(object.image.url)
  end

  def static_url
    full_asset_url(object.image.url(:static))
  end

  def category
    object.category.name
  end

  def category_loaded?
    object.association(:category).loaded? && object.category.present?
  end
end

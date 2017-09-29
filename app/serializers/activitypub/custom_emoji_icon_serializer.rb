# frozen_string_literal: true

class ActivityPub::CustomEmojiIconSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :type, :url

  def id
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def type
    'Image'
  end

  def url
    object.image_remote_url || full_asset_url(object.image.url)
  end
end

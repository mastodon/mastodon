# frozen_string_literal: true

class ActivityPub::ImageSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :type, :media_type, :url

  def type
    'Image'
  end

  def url
    full_asset_url(object.url(:original))
  end

  def media_type
    object.content_type
  end
end

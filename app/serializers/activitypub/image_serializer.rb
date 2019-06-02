# frozen_string_literal: true

class ActivityPub::ImageSerializer < ActivityPub::Serializer
  include RoutingHelper

  context_extensions :focal_point

  attributes :type, :media_type, :url
  attribute :focal_point, if: :focal_point?

  def type
    'Image'
  end

  def url
    full_asset_url(object.url(:original))
  end

  def media_type
    object.content_type
  end

  def focal_point?
    object.respond_to?(:meta) && object.meta.is_a?(Hash) && object.meta['focus'].is_a?(Hash)
  end

  def focal_point
    [object.meta['focus']['x'], object.meta['focus']['y']]
  end
end

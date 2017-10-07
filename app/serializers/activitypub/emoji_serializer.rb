# frozen_string_literal: true

class ActivityPub::EmojiSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :type, :name, :updated

  has_one :icon, serializer: ActivityPub::ImageSerializer

  def id
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def type
    'Emoji'
  end

  def icon
    object.image
  end

  def updated
    object.updated_at.iso8601
  end

  def name
    ":#{object.shortcode}:"
  end
end

class ActivityPub::CustomEmojiSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :type, :attributed_to, :href, :name

  def id
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def type
    'Emoji'
  end

  def attributed_to
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def href
    object.href || full_asset_url(object.image.url)
  end

  def name
    ":#{object.shortcode}:"
  end
end

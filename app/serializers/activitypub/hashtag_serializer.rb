# frozen_string_literal: true

class ActivityPub::HashtagSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :type, :href, :name

  def type
    'Hashtag'
  end

  def name
    "##{object.name}"
  end

  def href
    if object.class.name == 'FeaturedTag'
      short_account_tag_url(object.account, object.tag)
    else
      tag_url(object)
    end
  end
end

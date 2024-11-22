# frozen_string_literal: true

class ActivityPub::HashtagSerializer < ActivityPub::Serializer
  context_extensions :hashtag

  include RoutingHelper

  attributes :type, :href, :name

  def type
    'Hashtag'
  end

  def name
    "##{object.display_name}"
  end

  def href
    if object.instance_of?(FeaturedTag)
      short_account_tag_url(object.account, object.tag)
    else
      tag_url(object)
    end
  end
end

# frozen_string_literal: true

class ActivityPub::FeaturedItemSerializer < ActivityPub::Serializer
  attributes :id, :type, :featured_object, :featured_object_type

  def id
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def type
    'FeaturedItem'
  end

  def featured_object
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def featured_object_type
    object.account.actor_type || 'Person'
  end
end

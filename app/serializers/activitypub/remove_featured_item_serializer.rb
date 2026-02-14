# frozen_string_literal: true

class ActivityPub::RemoveFeaturedItemSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :type, :actor, :target
  has_one :virtual_object, key: :object

  def type
    'Remove'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(collection.account)
  end

  def target
    ActivityPub::TagManager.instance.uri_for(collection)
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object)
  end

  private

  def collection
    @collection ||= object.collection
  end
end

# frozen_string_literal: true

class ActivityPub::AddFeaturedItemSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :type, :actor, :target
  has_one :object, serializer: ActivityPub::FeaturedItemSerializer

  def type
    'Add'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(collection.account)
  end

  def target
    ActivityPub::TagManager.instance.uri_for(collection)
  end

  private

  def collection
    @collection ||= object.collection
  end
end

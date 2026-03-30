# frozen_string_literal: true

class ActivityPub::RemoveFeaturedCollectionSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :type, :actor, :target
  has_one :object_uri, key: :object

  def type
    'Remove'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def target
    ap_account_featured_collections_url(object.account_id)
  end

  def object_uri
    ActivityPub::TagManager.instance.uri_for(object)
  end
end

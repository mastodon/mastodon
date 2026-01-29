# frozen_string_literal: true

class ActivityPub::AddFeaturedCollectionSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :type, :actor, :target
  has_one :object, serializer: ActivityPub::FeaturedCollectionSerializer

  def type
    'Add'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def target
    ap_account_featured_collections_url(object.account_id)
  end
end

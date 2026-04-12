# frozen_string_literal: true

class ActivityPub::RejectFeatureRequestSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :id, :type, :actor, :to

  has_one :virtual_object, key: :object

  def id
    [ActivityPub::TagManager.instance.uri_for(object.account), '#rejects/feature_requests/', object.id].join
  end

  def type
    'Reject'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def to
    ActivityPub::TagManager.instance.uri_for(object.collection.account)
  end

  def virtual_object
    object.activity_uri
  end
end

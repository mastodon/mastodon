# frozen_string_literal: true

class ActivityPub::AcceptFeatureRequestSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :id, :type, :actor, :to, :result

  has_one :virtual_object, key: :object

  def id
    [ActivityPub::TagManager.instance.uri_for(object.account), '#accepts/feature_requests/', object.id].join
  end

  def type
    'Accept'
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

  def result
    ap_account_feature_authorization_url(object.account_id, object)
  end
end

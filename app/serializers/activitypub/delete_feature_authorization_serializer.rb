# frozen_string_literal: true

class ActivityPub::DeleteFeatureAuthorizationSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :id, :type, :actor, :to

  has_one :object, serializer: ActivityPub::FeatureAuthorizationSerializer

  def id
    [ap_account_feature_authorization_url(object.account_id, object), '#delete'].join
  end

  def type
    'Delete'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def to
    [ActivityPub::TagManager::COLLECTIONS[:public]]
  end
end

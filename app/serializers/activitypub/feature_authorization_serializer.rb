# frozen_string_literal: true

class ActivityPub::FeatureAuthorizationSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :id, :type, :interacting_object, :interaction_target

  def id
    ap_account_feature_authorization_url(object.account_id, object)
  end

  def type
    'FeatureAuthorization'
  end

  def interaction_target
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def interacting_object
    ActivityPub::TagManager.instance.uri_for(object.collection)
  end
end

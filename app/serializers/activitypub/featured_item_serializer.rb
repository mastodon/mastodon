# frozen_string_literal: true

class ActivityPub::FeaturedItemSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :id, :type, :featured_object, :featured_object_type,
             :feature_authorization

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

  def feature_authorization
    if object.account.local?
      ap_account_feature_authorization_url(object.account_id, object)
    else
      object.approval_uri
    end
  end
end

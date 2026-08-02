# frozen_string_literal: true

class ActivityPub::FeaturedItemSerializer < ActivityPub::Serializer
  include RoutingHelper

  context_extensions :featured_collections

  attributes :id, :type, :featured_object, :feature_authorization, :published

  def id
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def type
    'FeaturedItem'
  end

  def featured_object
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def feature_authorization
    if object.account.local?
      ap_account_feature_authorization_url(object.account_id, object)
    else
      object.approval_uri
    end
  end

  def published
    object.created_at.iso8601
  end
end

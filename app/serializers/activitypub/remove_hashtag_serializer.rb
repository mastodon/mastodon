# frozen_string_literal: true

class ActivityPub::RemoveHashtagSerializer < ActivityPub::Serializer
  include RoutingHelper

  attributes :type, :actor, :target
  has_one :proper_object, key: :object, serializer: ActivityPub::HashtagSerializer

  def type
    'Remove'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def proper_object
    object.tag
  end

  def target
    account_collection_url(object.account, :featured)
  end
end

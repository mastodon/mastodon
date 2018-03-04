# frozen_string_literal: true

class ActivityPub::RemoveSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :type, :actor, :origin
  attribute :proper_object, key: :object

  def id
    nil
  end

  def type
    'Remove'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def proper_object
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def origin
    account_collection_url(object, :featured)
  end
end

# frozen_string_literal: true

class ActivityPub::AddSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :type, :actor, :target
  attribute :proper_object, key: :object

  def type
    'Add'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def proper_object
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def target
    account_collection_url(object.account, :featured)
  end
end

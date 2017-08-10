# frozen_string_literal: true

class ActivityPub::DeleteSerializer < ActiveModel::Serializer
  attributes :id, :type, :actor
  attribute :virtual_object, key: :object

  def id
    [ActivityPub::TagManager.instance.uri_for(object), '#delete'].join
  end

  def type
    'Delete'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object)
  end
end

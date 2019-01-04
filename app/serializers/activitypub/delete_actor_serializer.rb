# frozen_string_literal: true

class ActivityPub::DeleteActorSerializer < ActiveModel::Serializer
  attributes :id, :type, :actor
  attribute :virtual_object, key: :object

  def id
    [ActivityPub::TagManager.instance.uri_for(object), '#delete'].join
  end

  def type
    'Delete'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def virtual_object
    actor
  end
end

# frozen_string_literal: true

class ActivityPub::Relay::UndoFollowSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor

  has_one :virtual_object, key: :object, serializer: ActivityPub::Relay::FollowSerializer

  def type
    'Undo'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.actor)
  end

  def virtual_object
    object.object
  end
end

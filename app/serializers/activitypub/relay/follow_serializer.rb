# frozen_string_literal: true

class ActivityPub::Relay::FollowSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor

  has_one :virtual_object, key: :object

  def type
    'Follow'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.actor)
  end

  def virtual_object
    ActivityPub::TagManager::COLLECTIONS[:public]
  end
end

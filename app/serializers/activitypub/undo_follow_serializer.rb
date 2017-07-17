# frozen_string_literal: true

class ActivityPub::UndoFollowSerializer < ActiveModel::Serializer
  attributes :type, :actor

  has_one :object, serializer: ActivityPub::FollowSerializer

  def type
    'Undo'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end
end

# frozen_string_literal: true

class ActivityPub::UndoFollowSerializer < ActiveModel::Serializer
  attributes :id, :type, :actor

  has_one :object, serializer: ActivityPub::FollowSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object.account), '#follows/', object.id, '/undo'].join
  end

  def type
    'Undo'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end
end

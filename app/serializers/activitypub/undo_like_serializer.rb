# frozen_string_literal: true

class ActivityPub::UndoLikeSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor

  has_one :object, serializer: ActivityPub::LikeSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object.account), '#likes/', object.id, '/undo'].join
  end

  def type
    'Undo'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end
end

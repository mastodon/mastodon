# frozen_string_literal: true

class ActivityPub::UndoLikeSerializer < ActiveModel::Serializer
  attributes :type, :actor

  has_one :object, serializer: ActivityPub::LikeSerializer

  def type
    'Undo'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end
end

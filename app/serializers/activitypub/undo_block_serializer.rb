# frozen_string_literal: true

class ActivityPub::UndoBlockSerializer < ActiveModel::Serializer
  attributes :type, :actor

  has_one :object, serializer: ActivityPub::BlockSerializer

  def type
    'Undo'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end
end

# frozen_string_literal: true

class ActivityPub::ActivitySerializer < ActiveModel::Serializer
  attributes :id, :type, :actor

  has_one :object, serializer: ActivityPub::NoteSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object), '/activity'].join
  end

  def type
    object.reblog? ? 'Announce' : 'Create'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end
end

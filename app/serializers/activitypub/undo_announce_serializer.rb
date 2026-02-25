# frozen_string_literal: true

class ActivityPub::UndoAnnounceSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :to

  has_one :virtual_object, key: :object, serializer: ActivityPub::AnnounceNoteSerializer do |serializer|
    serializer.send(:instance_options)[:allow_inlining] = false

    object
  end

  def id
    [ActivityPub::TagManager.instance.uri_for(object.account), '#announces/', object.id, '/undo'].join
  end

  def type
    'Undo'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def to
    [ActivityPub::TagManager::COLLECTIONS[:public]]
  end

  def virtual_object
    object
  end
end

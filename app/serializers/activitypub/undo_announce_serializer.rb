# frozen_string_literal: true

class ActivityPub::UndoAnnounceSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :to

  has_one :virtual_object, key: :object, serializer: ActivityPub::ActivitySerializer

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
    ActivityPub::ActivityPresenter.from_status(object, allow_inlining: false)
  end
end

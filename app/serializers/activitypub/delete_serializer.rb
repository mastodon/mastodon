# frozen_string_literal: true

class ActivityPub::DeleteSerializer < ActivityPub::Serializer
  class TombstoneSerializer < ActivityPub::Serializer
    attributes :id, :type

    def id
      ActivityPub::TagManager.instance.uri_for(object)
    end

    def type
      'Tombstone'
    end
  end

  attributes :id, :type, :actor, :to

  has_one :object, serializer: TombstoneSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object), '#delete'].join
  end

  def type
    'Delete'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def to
    [ActivityPub::TagManager::COLLECTIONS[:public]]
  end
end

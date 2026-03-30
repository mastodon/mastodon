# frozen_string_literal: true

class ActivityPub::DeleteNoteSerializer < ActivityPub::Serializer
  class TombstoneSerializer < ActivityPub::Serializer
    context_extensions :atom_uri

    attributes :id, :type, :atom_uri

    def id
      ActivityPub::TagManager.instance.uri_for(object)
    end

    def type
      'Tombstone'
    end

    def atom_uri
      OStatus::TagManager.instance.uri_for(object)
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

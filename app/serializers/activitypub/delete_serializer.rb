# frozen_string_literal: true

class ActivityPub::DeleteSerializer < ActiveModel::Serializer
  class TombstoneSerializer < ActiveModel::Serializer
    attributes :id, :type, :atom_uri

    def id
      ActivityPub::TagManager.instance.uri_for(object)
    end

    def type
      'Tombstone'
    end

    def atom_uri
      ::TagManager.instance.uri_for(object)
    end
  end

  attributes :id, :type, :actor

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
end

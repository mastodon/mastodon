# frozen_string_literal: true

class ActivityPub::VoteSerializer < ActiveModel::Serializer
  class NoteSerializer < ActiveModel::Serializer
    attributes :id, :type, :name, :attributed_to,
               :in_reply_to, :to

    def id
      nil
    end

    def type
      'Note'
    end

    def name
      object.poll.options[object.choice.to_i]
    end

    def attributed_to
      ActivityPub::TagManager.instance.uri_for(object.account)
    end

    def to
      ActivityPub::TagManager.instance.uri_for(object.poll.account)
    end
  end

  attributes :id, :type, :actor, :to

  has_one :object, serializer: ActivityPub::VoteSerializer::NoteSerializer

  def id
    nil
  end

  def type
    'Create'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def to
    ActivityPub::TagManager.instance.uri_for(object.poll.account)
  end
end

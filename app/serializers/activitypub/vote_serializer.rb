# frozen_string_literal: true

class ActivityPub::VoteSerializer < ActivityPub::Serializer
  class NoteSerializer < ActivityPub::Serializer
    attributes :id, :type, :name, :attributed_to,
               :in_reply_to, :to

    def id
      ActivityPub::TagManager.instance.uri_for(object) || [ActivityPub::TagManager.instance.uri_for(object.account), '#votes/', object.id].join
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

    def in_reply_to
      ActivityPub::TagManager.instance.uri_for(object.poll.status)
    end

    def to
      ActivityPub::TagManager.instance.uri_for(object.poll.account)
    end
  end

  attributes :id, :type, :actor, :to

  has_one :object, serializer: ActivityPub::VoteSerializer::NoteSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object.account), '#votes/', object.id, '/activity'].join
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

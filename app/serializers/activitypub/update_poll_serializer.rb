# frozen_string_literal: true

class ActivityPub::UpdatePollSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :to

  has_one :object, serializer: ActivityPub::NoteSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object), '#updates/', object.preloadable_poll.updated_at.to_i].join
  end

  def type
    'Update'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def to
    ActivityPub::TagManager.instance.to(object)
  end

  def cc
    ActivityPub::TagManager.instance.cc(object)
  end
end

# frozen_string_literal: true

class ActivityPub::UpdatePollSerializer < ActiveModel::Serializer
  attributes :id, :type, :actor, :to

  has_one :object, serializer: ActivityPub::NoteSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object), '#updates/', object.poll.updated_at.to_i].join
  end

  def type
    'Update'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def to
    ActivityPub::TagManager.instance.to(object)
  end

  def cc
    ActivityPub::TagManager.instance.cc(object)
  end
end

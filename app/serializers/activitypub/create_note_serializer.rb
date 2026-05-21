# frozen_string_literal: true

class ActivityPub::CreateNoteSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :published, :to, :cc

  has_one :object, serializer: ActivityPub::NoteSerializer

  def id
    ActivityPub::TagManager.instance.activity_uri_for(object)
  end

  def type
    'Create'
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

  def published
    object.created_at.iso8601
  end
end

# frozen_string_literal: true

class ActivityPub::ActivitySerializer < ActiveModel::Serializer
  attributes :id, :type, :actor, :published, :to, :cc

  has_one :proper, key: :object, serializer: ActivityPub::NoteSerializer

  def id
    [ActivityPub::TagManager.instance.activity_uri_for(object)].join
  end

  def type
    announce? ? 'Announce' : 'Create'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def published
    object.created_at.iso8601
  end

  def to
    ActivityPub::TagManager.instance.to(object)
  end

  def cc
    ActivityPub::TagManager.instance.cc(object)
  end

  def announce?
    object.reblog?
  end
end

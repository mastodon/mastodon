# frozen_string_literal: true

class ActivityPub::ActivitySerializer < ActiveModel::Serializer
  attributes :id, :type, :actor, :to, :cc

  has_one :proper, key: :object, serializer: ActivityPub::NoteSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object), '/activity'].join
  end

  def type
    object.reblog? ? 'Announce' : 'Create'
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

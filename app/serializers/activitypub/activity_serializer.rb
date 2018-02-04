# frozen_string_literal: true

class ActivityPub::ActivitySerializer < ActiveModel::Serializer
  attributes :id, :type, :actor, :published, :to, :cc

  has_one :proper, key: :object, serializer: ActivityPub::NoteSerializer, unless: :announce?
  attribute :proper_uri, key: :object, if: :announce?
  attribute :atom_uri, if: :announce?

  def id
    ActivityPub::TagManager.instance.activity_uri_for(object)
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

  def proper_uri
    ActivityPub::TagManager.instance.uri_for(object.proper)
  end

  def atom_uri
    OStatus::TagManager.instance.uri_for(object)
  end

  def announce?
    object.reblog?
  end
end

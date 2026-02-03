# frozen_string_literal: true

class ActivityPub::AnnounceNoteSerializer < ActivityPub::Serializer
  def self.serializer_for(model, options)
    return ActivityPub::NoteSerializer if model.is_a?(Status)

    super
  end

  attributes :id, :type, :actor, :published, :to, :cc

  has_one :virtual_object, key: :object

  def id
    ActivityPub::TagManager.instance.activity_uri_for(object)
  end

  def type
    'Announce'
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

  def virtual_object
    if allow_inlining? && object.account == object.proper.account && object.proper.private_visibility? && object.local?
      object.proper
    else
      ActivityPub::TagManager.instance.uri_for(object.proper)
    end
  end

  private

  def allow_inlining?
    return instance_options[:allow_inlining] if instance_options.key?(:allow_inlining)

    true
  end
end

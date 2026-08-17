# frozen_string_literal: true

class ActivityPub::UpdateNoteSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :published, :to, :cc

  has_one :object, serializer: ActivityPub::NoteSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object), '#updates/', edited_at.to_i].join
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

  def published
    edited_at.iso8601
  end

  private

  def edited_at
    instance_options[:updated_at]&.to_datetime || object.edited_at
  end
end

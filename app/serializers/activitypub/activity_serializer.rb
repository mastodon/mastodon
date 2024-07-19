# frozen_string_literal: true

class ActivityPub::ActivitySerializer < ActivityPub::Serializer
  def self.serializer_for(model, options)
    case model.class.name
    when 'Status'
      ActivityPub::NoteSerializer
    else
      super
    end
  end

  attributes :id, :type, :actor, :published, :to, :cc

  has_one :virtual_object, key: :object

  def published
    object.published.iso8601
  end
end

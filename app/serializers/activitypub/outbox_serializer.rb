# frozen_string_literal: true

class ActivityPub::OutboxSerializer < ActivityPub::CollectionSerializer
  def self.serializer_for(model, options)
    case model
    when Status
      model.reblog? ? ActivityPub::AnnounceNoteSerializer : ActivityPub::CreateNoteSerializer
    else
      super
    end
  end

  def items
    object.items
  end
end

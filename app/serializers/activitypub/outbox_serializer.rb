# frozen_string_literal: true

class ActivityPub::OutboxSerializer < ActivityPub::CollectionSerializer
  def self.serializer_for(model, options)
    return ActivityPub::ActivitySerializer if model.class.name == 'Status'
    super
  end
end

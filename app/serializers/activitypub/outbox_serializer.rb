# frozen_string_literal: true

class ActivityPub::OutboxSerializer < ActivityPub::CollectionSerializer
  def self.serializer_for(model, options)
    return ActivityPub::ActivitySerializer if model.is_a?(Status)
    super
  end
end

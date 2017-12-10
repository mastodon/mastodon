# frozen_string_literal: true

class Streaming::CardSerializer < ActiveModel::Serializer
  attributes :event, :payload

  def self.serializer_for(model, options)
    return REST::PreviewCardSerializer if model.class == 'PreviewCard'
    super
  end

  def event
    'card'
  end

  def payload
    { id: object.id, card: object.preview_cards.first }
  end
end

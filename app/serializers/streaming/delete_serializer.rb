# frozen_string_literal: true

class Streaming::DeleteSerializer < ActiveModel::Serializer
  attributes :event, :payload

  def event
    'delete'
  end

  def payload
    object.id.to_s
  end
end

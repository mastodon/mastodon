# frozen_string_literal: true

class Streaming::UpdateSerializer < ActiveModel::Serializer
  attributes :event, :payload, :queued_at

  def event
    'update'
  end

  def payload
    Oj.dump(ActiveModelSerializers::SerializableResource.new(
      object,
      serializer: REST::StatusSerializer,
      scope: current_user,
      scope_name: :current_user
    ).as_json)
  end

  def queued_at
    (Time.now.to_f * 1000.0).to_i
  end
end

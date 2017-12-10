# frozen_string_literal: true

class Streaming::NotificationSerializer < ActiveModel::Serializer
  attributes :event, :payload

  def event
    'notification'
  end

  def payload
    Oj.dump(ActiveModelSerializers::SerializableResource.new(
      object,
      scope: current_user,
      scope_name: :current_user,
      serializer: REST::NotificationSerializer
    ).as_json)
  end
end

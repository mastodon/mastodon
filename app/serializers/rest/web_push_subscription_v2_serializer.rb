# frozen_string_literal: true

class REST::WebPushSubscriptionV2Serializer < ActiveModel::Serializer
  attributes :id, :endpoint, :standard, :alerts, :server_key, :policy

  delegate :standard, to: :object

  def id
    object.id.to_s
  end

  def alerts
    (object.data&.dig('alerts') || {}).transform_values { |v| ActiveModel::Type::Boolean.new.cast(v) }
  end

  def server_key
    Rails.configuration.x.vapid.public_key
  end

  def policy
    object.data&.dig('policy') || 'all'
  end
end

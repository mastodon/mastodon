# frozen_string_literal: true

class REST::WebPushSubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :endpoint, :standard, :alerts, :server_key, :policy

  delegate :standard, to: :object

  def alerts
    (object.data&.dig('alerts') || {}).each_with_object({}) { |(k, v), h| h[k] = ActiveModel::Type::Boolean.new.cast(v) }
  end

  def server_key
    Rails.configuration.x.vapid_public_key
  end

  def policy
    object.data&.dig('policy') || 'all'
  end
end

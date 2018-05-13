# frozen_string_literal: true

class REST::WebPushSubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :endpoint, :alerts, :server_key

  def alerts
    object.data&.dig('alerts') || {}
  end

  def server_key
    Rails.configuration.x.vapid_public_key
  end
end

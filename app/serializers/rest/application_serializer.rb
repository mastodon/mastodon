# frozen_string_literal: true

class REST::ApplicationSerializer < ActiveModel::Serializer
  attributes :id, :name, :website, :scopes, :redirect_uris

  # NOTE: Deprecated in 4.3.0, needs to be removed in 5.0.0
  attribute :vapid_key

  # We should consider this property deprecated for 4.3.0
  attribute :redirect_uri

  def id
    object.id.to_s
  end

  def website
    object.website.presence
  end

  def vapid_key
    Rails.configuration.x.vapid_public_key
  end
end

# frozen_string_literal: true

class REST::ApplicationSerializer < ActiveModel::Serializer
  attributes :id, :name, :website, :scopes, :redirect_uris

  # We should consider this property deprecated for 4.3.0
  attribute :redirect_uri

  def id
    object.id.to_s
  end

  def website
    object.website.presence
  end
end

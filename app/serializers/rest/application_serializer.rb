# frozen_string_literal: true

class REST::ApplicationSerializer < ActiveModel::Serializer
  attributes :id, :name, :website, :scopes, :redirect_uri, :redirect_uris,
             :client_id, :client_secret

  # NOTE: Deprecated in 4.3.0, needs to be removed in 5.0.0
  attribute :vapid_key

  def id
    object.id.to_s
  end

  def client_id
    object.uid
  end

  def client_secret
    object.secret
  end

  # We should consider this property deprecated for 4.3.0
  delegate :redirect_uri, to: :object

  def redirect_uris
    # Doorkeeper stores the redirect_uri value as a newline delimeted list in
    # the database:
    object.redirect_uri.split
  end

  def website
    object.website.presence
  end

  def vapid_key
    Rails.configuration.x.vapid_public_key
  end
end

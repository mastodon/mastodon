# frozen_string_literal: true

class REST::ApplicationSerializer < ActiveModel::Serializer
  attributes :id, :name, :website, :redirect_uri,
             :client_id, :client_secret, :vapid_key

  def id
    object.id.to_s
  end

  def client_id
    object.uid
  end

  def client_secret
    object.secret
  end

  def website
    object.website.presence
  end

  def vapid_key
    Rails.configuration.x.vapid_public_key
  end
end

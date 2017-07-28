# frozen_string_literal: true

class REST::ApplicationSerializer < ActiveModel::Serializer
  attributes :id, :name, :website, :redirect_uri,
             :client_id, :client_secret

  def client_id
    object.uid
  end

  def client_secret
    object.secret
  end
end

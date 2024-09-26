# frozen_string_literal: true

class REST::CredentialApplicationSerializer < REST::ApplicationSerializer
  attributes :client_id, :client_secret

  def client_id
    object.uid
  end

  def client_secret
    object.secret
  end
end

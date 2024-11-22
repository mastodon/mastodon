# frozen_string_literal: true

class REST::CredentialApplicationSerializer < REST::ApplicationSerializer
  attributes :client_id, :client_secret, :client_secret_expires_at

  def client_id
    object.uid
  end

  def client_secret
    object.secret
  end

  # Added for future forwards compatibility when we may decide to expire OAuth
  # Applications. Set to zero means that the client_secret never expires.
  def client_secret_expires_at
    0
  end
end

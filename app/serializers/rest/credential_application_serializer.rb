# frozen_string_literal: true

class REST::CredentialApplicationSerializer < REST::ApplicationSerializer
  attributes :client_secret

  def client_secret
    object.secret
  end
end

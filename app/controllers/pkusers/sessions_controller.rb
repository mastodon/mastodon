# frozen_string_literal: true

class Pkusers::SessionsController < Devise::SessionsController
  include Devise::Passkeys::Controllers::SessionsControllerConcern
  include RelyingParty
  def set_relying_party_in_request_env
    request.env[relying_party_key] = relying_party
  end

end

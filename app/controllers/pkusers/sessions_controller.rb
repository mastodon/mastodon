# frozen_string_literal: true

class Pkusers::SessionsController < Devise::SessionsController
  include RelyingParty

  include Devise::Passkeys::Controllers::SessionsControllerConcern
  def set_relying_party_in_request_env
    request.env[relying_party_key] = relying_party
  end

end

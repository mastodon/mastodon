# frozen_string_literal: true

class Auth::PasskeysController < DeviseController
  layout 'auth'

  include RelyingParty

  include Devise::Passkeys::Controllers::PasskeysControllerConcern

  def set_relying_party_in_request_env
    request.env[relying_party_key] = relying_party
  end

end

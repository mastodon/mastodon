# frozen_string_literal: true

class Auth::ReauthenticationController < DeviseController
  layout 'auth'

  include RelyingParty

  include Devise::Passkeys::Controllers::ReauthenticationControllerConcern

  def set_relying_party_in_request_env
    request.env[relying_party_key] = relying_party
  end


end

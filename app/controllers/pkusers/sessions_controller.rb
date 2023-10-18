# frozen_string_literal: true

class Pkusers::SessionsController < Devise::SessionsController
  include Devise::Passkeys::Controllers::SessionsControllerConcern
  include RelyingParty

#  skip_before_action :require_authenticated_user!
#  skip_before_action :require_not_suspended!
  skip_before_action :require_functional!

    skip_around_action :set_locale
    skip_before_action :update_user_sign_in
  def set_relying_party_in_request_env
    request.env[relying_party_key] = relying_party
  end

end

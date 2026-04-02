# frozen_string_literal: true

class Auth::Sessions::SecurityKeyOptionsController < ApplicationController
  skip_before_action :check_self_destruct!
  skip_before_action :require_functional!
  skip_before_action :update_user_sign_in

  def show
    user = User.find_by(id: session[:attempt_user_id])

    if user&.webauthn_enabled?
      options_for_get = WebAuthn::Credential.options_for_get(
        allow: user.webauthn_credentials.pluck(:external_id),
        user_verification: 'discouraged'
      )

      session[:webauthn_challenge] = options_for_get.challenge

      render json: options_for_get, status: 200
    else
      render json: { error: t('webauthn_credentials.not_enabled') }, status: 401
    end
  end
end

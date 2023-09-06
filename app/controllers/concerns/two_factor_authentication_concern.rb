# frozen_string_literal: true

module TwoFactorAuthenticationConcern
  extend ActiveSupport::Concern

  included do
    prepend_before_action :authenticate_with_two_factor, if: :two_factor_enabled?, only: [:create]
  end

  def two_factor_enabled?
    find_user&.two_factor_enabled?
  end

  def valid_webauthn_credential?(user, webauthn_credential)
    user_credential = user.webauthn_credentials.find_by!(external_id: webauthn_credential.id)

    begin
      webauthn_credential.verify(
        session[:webauthn_challenge],
        public_key: user_credential.public_key,
        sign_count: user_credential.sign_count
      )

      user_credential.update!(sign_count: webauthn_credential.sign_count)
    rescue WebAuthn::Error
      false
    end
  end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt]) ||
      user.invalidate_otp_backup_code!(user_params[:otp_attempt])
  rescue OpenSSL::Cipher::CipherError
    false
  end

  def authenticate_with_two_factor
    if user_params[:email].present?
      user = self.resource = find_user_from_params
      prompt_for_two_factor(user) if user&.external_or_valid_password?(user_params[:password])
    elsif session[:attempt_user_id]
      user = self.resource = User.find_by(id: session[:attempt_user_id])
      return if user.nil?

      if session[:attempt_user_updated_at] != user.updated_at.to_s
        restart_session
      elsif user.webauthn_enabled? && user_params.key?(:credential)
        authenticate_with_two_factor_via_webauthn(user)
      elsif user_params.key?(:otp_attempt)
        authenticate_with_two_factor_via_otp(user)
      end
    end
  end

  def authenticate_with_two_factor_via_webauthn(user)
    webauthn_credential = WebAuthn::Credential.from_get(user_params[:credential])

    if valid_webauthn_credential?(user, webauthn_credential)
      on_authentication_success(user, :webauthn)
      render json: { redirect_path: after_sign_in_path_for(user) }, status: 200
    else
      on_authentication_failure(user, :webauthn, :invalid_credential)
      render json: { error: t('webauthn_credentials.invalid_credential') }, status: 422
    end
  end

  def authenticate_with_two_factor_via_otp(user)
    if valid_otp_attempt?(user)
      on_authentication_success(user, :otp)
    else
      on_authentication_failure(user, :otp, :invalid_otp_token)
      flash.now[:alert] = I18n.t('users.invalid_otp_token')
      prompt_for_two_factor(user)
    end
  end

  def prompt_for_two_factor(user)
    register_attempt_in_session(user)

    use_pack 'auth'

    @body_classes     = 'lighter'
    @webauthn_enabled = user.webauthn_enabled?
    @scheme_type      = if user.webauthn_enabled? && user_params[:otp_attempt].blank?
                          'webauthn'
                        else
                          'totp'
                        end

    set_locale { render :two_factor }
  end
end

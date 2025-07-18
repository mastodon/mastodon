# frozen_string_literal: true

module MfaForceConcern
  extend ActiveSupport::Concern

  included do
    before_action :check_mfa_requirement, if: :user_signed_in?
  end

  private

  def check_mfa_requirement
    return unless mfa_force_enabled?
    return if current_user.otp_enabled?
    return if mfa_setup_allowed_paths?

    flash[:warning] = I18n.t('mfa_force.required_message')
    redirect_to settings_otp_authentication_path
  end

  def mfa_force_enabled?
    ENV['MFA_FORCE'] == 'true'
  end

  def mfa_setup_allowed_paths?
    allowed_paths = [
      settings_otp_authentication_path,
      new_settings_two_factor_authentication_confirmation_path,
      settings_two_factor_authentication_confirmation_path,
      settings_two_factor_authentication_methods_path,
      settings_two_factor_authentication_recovery_codes_path,
      destroy_user_session_path,
      auth_setup_path,
      edit_user_registration_path,
    ]

    allowed_paths.any? { |path| request.path.start_with?(path) }
  end
end

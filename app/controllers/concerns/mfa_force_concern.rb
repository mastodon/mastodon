# frozen_string_literal: true

module MfaForceConcern
  extend ActiveSupport::Concern

  included do
    prepend_before_action :check_mfa_requirement, if: :user_signed_in?
  end

  private

  def check_mfa_requirement
    return unless mfa_force_enabled?
    return if current_user.otp_enabled?

    flash[:alert] = I18n.t('require_multi_factor_auth.required_message')
    redirect_to settings_otp_authentication_path
  end

  def mfa_force_enabled?
    mfa_config[:force_enabled]
  end

  def mfa_config
    @mfa_config ||= Rails.application.config_for(:mfa)
  end
end

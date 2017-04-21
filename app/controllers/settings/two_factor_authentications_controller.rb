# frozen_string_literal: true

module Settings
  class TwoFactorAuthenticationsController < ApplicationController
    layout 'admin'

    before_action :authenticate_user!
    before_action :verify_otp_required, only: [:create]

    def show; end

    def create
      current_user.otp_secret = User.generate_otp_secret(32)
      current_user.save!
      redirect_to new_settings_two_factor_authentication_confirmation_path
    end

    def destroy
      current_user.otp_required_for_login = false
      current_user.save!
      redirect_to settings_two_factor_authentication_path
    end

    private

    def verify_otp_required
      redirect_to settings_two_factor_authentication_path if current_user.otp_required_for_login?
    end
  end
end

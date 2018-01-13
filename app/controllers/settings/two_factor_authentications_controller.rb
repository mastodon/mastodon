# frozen_string_literal: true

module Settings
  class TwoFactorAuthenticationsController < ApplicationController
    layout 'admin'

    before_action :authenticate_user!
    before_action :verify_otp_required, only: [:create]

    def show
      @confirmation = Form::TwoFactorConfirmation.new
      @recovery_confirmation = Form::RecoveryCodeConfirmation.new
    end

    def create
      current_user.otp_secret = User.generate_otp_secret(32)
      current_user.save!
      redirect_to new_settings_two_factor_authentication_confirmation_path
    end

    def destroy
      valid_password = current_user.valid_password?(confirmation_params[:password])
      if acceptable_code? && valid_password
        current_user.otp_required_for_login = false
        current_user.save!
        UserMailer.two_factor_disabled(current_user).deliver_later
        redirect_to settings_two_factor_authentication_path
      else
        flash.now[:alert] = I18n.t(valid_password ? 'two_factor_authentication.wrong_code' : 'two_factor_authentication.bad_password_msg')
        @confirmation = Form::TwoFactorConfirmation.new
        @recovery_confirmation = Form::RecoveryCodeConfirmation.new
        render :show
      end
    end

    private

    def confirmation_params
      params.require(:form_two_factor_confirmation).permit(:password, :code)
    end

    def verify_otp_required
      redirect_to settings_two_factor_authentication_path if current_user.otp_required_for_login?
    end

    def acceptable_code?
      current_user.validate_and_consume_otp!(confirmation_params[:code]) ||
        current_user.invalidate_otp_backup_code!(confirmation_params[:code])
    end
  end
end

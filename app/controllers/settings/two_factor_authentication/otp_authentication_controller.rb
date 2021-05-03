# frozen_string_literal: true

module Settings
  module TwoFactorAuthentication
    class OtpAuthenticationController < BaseController
      include ChallengableConcern

      skip_before_action :require_functional!

      before_action :verify_otp_not_enabled, only: [:show]
      before_action :require_challenge!, only: [:create]

      def show
        @confirmation = Form::TwoFactorConfirmation.new
      end

      def create
        session[:new_otp_secret] = User.generate_otp_secret(32)

        redirect_to new_settings_two_factor_authentication_confirmation_path
      end

      private

      def confirmation_params
        params.require(:form_two_factor_confirmation).permit(:otp_attempt)
      end

      def verify_otp_not_enabled
        redirect_to settings_two_factor_authentication_methods_path if current_user.otp_enabled?
      end

      def acceptable_code?
        current_user.validate_and_consume_otp!(confirmation_params[:otp_attempt]) ||
          current_user.invalidate_otp_backup_code!(confirmation_params[:otp_attempt])
      end
    end
  end
end

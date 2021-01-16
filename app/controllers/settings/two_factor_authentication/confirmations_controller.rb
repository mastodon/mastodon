# frozen_string_literal: true

module Settings
  module TwoFactorAuthentication
    class ConfirmationsController < BaseController
      include ChallengableConcern

      skip_before_action :require_functional!

      before_action :require_challenge!
      before_action :ensure_otp_secret

      def new
        prepare_two_factor_form
      end

      def create
        if current_user.validate_and_consume_otp!(confirmation_params[:otp_attempt], otp_secret: session[:new_otp_secret])
          flash.now[:notice] = I18n.t('two_factor_authentication.enabled_success')

          current_user.otp_required_for_login = true
          current_user.otp_secret = session[:new_otp_secret]
          @recovery_codes = current_user.generate_otp_backup_codes!
          current_user.save!

          UserMailer.two_factor_enabled(current_user).deliver_later!

          session.delete(:new_otp_secret)

          render 'settings/two_factor_authentication/recovery_codes/index'
        else
          flash.now[:alert] = I18n.t('otp_authentication.wrong_code')
          prepare_two_factor_form
          render :new
        end
      end

      private

      def confirmation_params
        params.require(:form_two_factor_confirmation).permit(:otp_attempt)
      end

      def prepare_two_factor_form
        @confirmation = Form::TwoFactorConfirmation.new
        @new_otp_secret = session[:new_otp_secret]
        @provision_url = current_user.otp_provisioning_uri(current_user.email,
                                                           otp_secret: @new_otp_secret,
                                                           issuer: Rails.configuration.x.local_domain)
        @qrcode = RQRCode::QRCode.new(@provision_url)
      end

      def ensure_otp_secret
        redirect_to settings_otp_authentication_path if session[:new_otp_secret].blank?
      end
    end
  end
end

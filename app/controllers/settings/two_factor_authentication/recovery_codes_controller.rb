# frozen_string_literal: true

module Settings
  module TwoFactorAuthentication
    class RecoveryCodesController < ApplicationController
      layout 'admin'

      before_action :authenticate_user!

      def create
        if current_user.valid_password?(resource_params[:password])
          @recovery_codes = current_user.generate_otp_backup_codes!
          current_user.save!
          flash[:notice] = I18n.t('two_factor_authentication.recovery_codes_regenerated')
          render :index
        else
          redirect_to settings_two_factor_authentication_path,
                      alert: I18n.t('two_factor_authentication.bad_password_msg')
        end
      end

      private

      def resource_params
        params.require(:form_recovery_code_confirmation).permit(:password)
      end
    end
  end
end

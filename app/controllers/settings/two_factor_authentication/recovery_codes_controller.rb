# frozen_string_literal: true

module Settings
  module TwoFactorAuthentication
    class RecoveryCodesController < ApplicationController
      layout 'admin'

      before_action :authenticate_user!

      def create
        valid_password = current_user.valid_password?(resource_params[:password])
        if acceptable_code? && valid_password
          @recovery_codes = current_user.generate_otp_backup_codes!
          current_user.save!
          UserMailer.recovery_codes_regenerated(current_user).deliver_later
          flash[:notice] = I18n.t('two_factor_authentication.recovery_codes_regenerated')
          render :index
        else
          # i18n-tasks-use t('two_factor_authentication.bad_password_msg')
          redirect_to settings_two_factor_authentication_path,
                      alert: I18n.t(valid_password ? 'two_factor_authentication.wrong_code' : 'two_factor_authentication.bad_password_msg')
        end
      end

      private

      def resource_params
        params.require(:form_recovery_code_confirmation).permit(:password, :code)
      end

      def acceptable_code?
        current_user.validate_and_consume_otp!(resource_params[:code]) ||
          current_user.invalidate_otp_backup_code!(resource_params[:code])
      end
    end
  end
end

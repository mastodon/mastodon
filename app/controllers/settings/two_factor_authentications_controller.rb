# frozen_string_literal: true

module Settings
  class TwoFactorAuthenticationsController < BaseController
    include ChallengableConcern

    layout 'admin'

    before_action :authenticate_user!
    before_action :verify_otp_required, only: [:create]
    before_action :require_challenge!, only: [:create]

    skip_before_action :require_functional!

    def show
      @confirmation = Form::TwoFactorConfirmation.new
    end

    def create
      current_user.otp_secret = User.generate_otp_secret(32)
      current_user.save!
      redirect_to new_settings_two_factor_authentication_confirmation_path
    end

    def destroy
      if acceptable_code?
        current_user.otp_required_for_login = false
        current_user.save!
        UserMailer.two_factor_disabled(current_user).deliver_later!
        redirect_to settings_two_factor_authentication_path
      else
        flash.now[:alert] = I18n.t('two_factor_authentication.wrong_code')
        @confirmation = Form::TwoFactorConfirmation.new
        render :show
      end
    end

    private

    def confirmation_params
      params.require(:form_two_factor_confirmation).permit(:otp_attempt)
    end

    def verify_otp_required
      redirect_to settings_two_factor_authentication_path if current_user.otp_required_for_login?
    end

    def acceptable_code?
      current_user.validate_and_consume_otp!(confirmation_params[:otp_attempt]) ||
        current_user.invalidate_otp_backup_code!(confirmation_params[:otp_attempt])
    end
  end
end

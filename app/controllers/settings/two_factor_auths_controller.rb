# frozen_string_literal: true

class Settings::TwoFactorAuthsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show; end

  def new
    redirect_to settings_two_factor_auth_path if current_user.otp_required_for_login

    @confirmation = Form::TwoFactorConfirmation.new
    current_user.otp_secret = User.generate_otp_secret(32)
    current_user.save!
    set_qr_code
  end

  def create
    if current_user.validate_and_consume_otp!(confirmation_params[:code])
      current_user.otp_required_for_login = true
      current_user.save!

      redirect_to settings_two_factor_auth_path, notice: I18n.t('two_factor_auth.enabled_success')
    else
      @confirmation = Form::TwoFactorConfirmation.new
      set_qr_code
      flash.now[:alert] = I18n.t('two_factor_auth.wrong_code')
      render action: :new
    end
  end

  def disable
    current_user.otp_required_for_login = false
    current_user.save!

    redirect_to settings_two_factor_auth_path
  end

  private

  def set_qr_code
    @provision_url = current_user.otp_provisioning_uri(current_user.email, issuer: Rails.configuration.x.local_domain)
    @qrcode        = RQRCode::QRCode.new(@provision_url)
  end

  def confirmation_params
    params.require(:form_two_factor_confirmation).permit(:code)
  end
end

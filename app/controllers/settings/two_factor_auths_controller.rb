# frozen_string_literal: true

class Settings::TwoFactorAuthsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :verify_otp_required, only: [:new]

  def show; end

  def new
    current_user.otp_secret = User.generate_otp_secret(32)
    current_user.save!
    prepare_two_factor_form
  end

  def create
    if current_user.validate_and_consume_otp!(confirmation_params[:code])
      current_user.otp_required_for_login = true
      @codes = current_user.generate_otp_backup_codes!
      current_user.save!
      flash[:notice] = I18n.t('two_factor_auth.enabled_success')
    else
      flash.now[:alert] = I18n.t('two_factor_auth.wrong_code')
      prepare_two_factor_form
      render :new
    end
  end

  def recovery_codes
    @codes = current_user.generate_otp_backup_codes!
    current_user.save!
    flash[:notice] = I18n.t('two_factor_auth.recovery_codes_regenerated')
  end

  def disable
    current_user.otp_required_for_login = false
    current_user.save!

    redirect_to settings_two_factor_auth_path
  end

  private

  def verify_otp_required
    if current_user.otp_required_for_login?
      redirect_to settings_two_factor_auth_path
    end
  end

  def prepare_two_factor_form
    @confirmation = Form::TwoFactorConfirmation.new
    set_qr_code
  end

  def set_qr_code
    @provision_url = current_user.otp_provisioning_uri(current_user.email, issuer: Rails.configuration.x.local_domain)
    @qrcode        = RQRCode::QRCode.new(@provision_url)
  end

  def confirmation_params
    params.require(:form_two_factor_confirmation).permit(:code)
  end
end

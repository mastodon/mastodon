# frozen_string_literal: true

class Settings::TwoFactorAuthenticationsController < ApplicationController
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
      flash[:notice] = I18n.t('two_factor_authentication.enabled_success')

      current_user.otp_required_for_login = true
      @recovery_codes = current_user.generate_otp_backup_codes!
      current_user.save!

      render 'settings/recovery_codes/index'
    else
      flash.now[:alert] = I18n.t('two_factor_authentication.wrong_code')
      prepare_two_factor_form
      render :new
    end
  end

  def destroy
    current_user.otp_required_for_login = false
    current_user.save!

    redirect_to settings_two_factor_authentication_path
  end

  private

  def verify_otp_required
    if current_user.otp_required_for_login?
      redirect_to settings_two_factor_authentication_path
    end
  end

  def prepare_two_factor_form
    @confirmation = Form::TwoFactorConfirmation.new
    @provision_url = current_user.otp_provisioning_uri(current_user.email, issuer: Rails.configuration.x.local_domain)
    @qrcode = RQRCode::QRCode.new(@provision_url)
  end

  def confirmation_params
    params.require(:form_two_factor_confirmation).permit(:code)
  end
end

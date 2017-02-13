# frozen_string_literal: true

class Settings::TwoFactorAuthsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show
    return unless current_user.otp_required_for_login

    @provision_url = current_user.otp_provisioning_uri(current_user.email, issuer: Rails.configuration.x.local_domain)
    @qrcode        = RQRCode::QRCode.new(@provision_url)
  end

  def enable
    current_user.otp_required_for_login = true
    current_user.otp_secret = User.generate_otp_secret
    current_user.save!

    redirect_to settings_two_factor_auth_path
  end

  def disable
    current_user.otp_required_for_login = false
    current_user.save!

    redirect_to settings_two_factor_auth_path
  end
end

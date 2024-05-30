# frozen_string_literal: true

module RegistrationHelper
  extend ActiveSupport::Concern

  def allowed_registration?(remote_ip, invite)
    !Rails.configuration.x.single_user_mode && !omniauth_only? && (registrations_open? || invite&.valid_for_use?) && !ip_blocked?(remote_ip)
  end

  def registrations_open?
    Setting.registrations_mode != 'none'
  end

  def omniauth_only?
    Rails.configuration.omniauth.only
  end

  def ip_blocked?(remote_ip)
    IpBlock.where(severity: :sign_up_block).exists?(['ip >>= ?', remote_ip.to_s])
  end
end

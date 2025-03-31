# frozen_string_literal: true

module RegistrationHelper
  extend ActiveSupport::Concern

  def allowed_registration?(remote_ip, invite)
    !Rails.configuration.x.single_user_mode && !omniauth_only? && (registrations_open? || invite&.valid_for_use?) && !ip_blocked?(remote_ip)
  end

  def registration_agreement_label
    if TermsOfService.live.exists?
      t('auth.user_agreement_html', privacy_policy_path: privacy_policy_path, terms_of_service_path: terms_of_service_path)
    else
      t('auth.user_privacy_agreement_html', privacy_policy_path: privacy_policy_path)
    end
  end

  def registrations_open?
    Setting.registrations_mode != 'none'
  end

  def omniauth_only?
    ENV['OMNIAUTH_ONLY'] == 'true'
  end

  def ip_blocked?(remote_ip)
    IpBlock.severity_sign_up_block.containing(remote_ip.to_s).exists?
  end
end

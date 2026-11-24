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
    ENV['OMNIAUTH_ONLY'] == 'true'
  end

  def ip_blocked?(remote_ip)
    IpBlock.severity_sign_up_block.containing(remote_ip.to_s).exists?
  end

  def terms_agreement_label
    if TermsOfService.live.exists?
      t('auth.user_agreement_html', privacy_policy_path: privacy_policy_path, terms_of_service_path: terms_of_service_path)
    else
      t('auth.user_privacy_agreement_html', privacy_policy_path: privacy_policy_path)
    end
  end

  def pre_auth_from_stored_location
    url = session[:user_return_to]
    return if url.blank?

    # TODO: Use Rack instead for consistency?
    params = Addressable::URI.parse(url).query_values.with_indifferent_access
    pre_auth_params = params.slice(:client_id, :code_challenge, :code_challenge_method, :response_type, :response_mode, :redirect_uri, :scope, :state)

    pre_auth = Doorkeeper::OAuth::PreAuthorization.new(
      Doorkeeper.configuration,
      pre_auth_params,
      nil
    )

    return unless pre_auth.client_valid? && pre_auth.authorizable?

    pre_auth
  end
end

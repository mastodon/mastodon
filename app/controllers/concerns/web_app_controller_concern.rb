# frozen_string_literal: true

module WebAppControllerConcern
  extend ActiveSupport::Concern

  included do
    vary_by 'Accept, Accept-Language, Cookie'

    before_action :redirect_unauthenticated_to_permalinks!
    before_action :set_referer_header
    before_action :redirect_to_tos_interstitial!

    content_security_policy do |p|
      policy = ContentSecurityPolicy.new

      if policy.sso_host.present?
        p.form_action policy.sso_host, -> { "https://#{request.host}/auth/auth/" }
      else
        p.form_action :none
      end
    end
  end

  def skip_csrf_meta_tags?
    !(ENV['ONE_CLICK_SSO_LOGIN'] == 'true' && ENV['OMNIAUTH_ONLY'] == 'true' && Devise.omniauth_providers.length == 1) && current_user.nil?
  end

  def redirect_unauthenticated_to_permalinks!
    return if user_signed_in? && current_account.moved_to_account_id.nil?

    permalink_redirector = PermalinkRedirector.new(request.original_fullpath)
    return if permalink_redirector.redirect_path.blank?

    expires_in(15.seconds, public: true, stale_while_revalidate: 30.seconds, stale_if_error: 1.day) unless user_signed_in?

    respond_to do |format|
      format.html do
        redirect_to(permalink_redirector.redirect_confirmation_path, allow_other_host: false)
      end

      format.json do
        redirect_to(permalink_redirector.redirect_uri, allow_other_host: true)
      end
    end
  end

  protected

  def redirect_to_tos_interstitial!
    return unless current_user&.require_tos_interstitial?

    @terms_of_service = TermsOfService.published.first

    # Handle case where terms of service have been removed from the database
    if @terms_of_service.nil?
      current_user.update(require_tos_interstitial: false)
      return
    end

    render 'terms_of_service_interstitial/show', layout: 'auth'
  end

  def set_referer_header
    response.set_header('Referrer-Policy', Setting.allow_referrer_origin ? 'strict-origin-when-cross-origin' : 'same-origin')
  end
end

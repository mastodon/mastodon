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
        # Validate the redirect URI before allowing an external redirect.
        safe_uri, is_trusted = safe_redirect_uri_and_trust_status(permalink_redirector.redirect_uri)
        if safe_uri.present?
          # Only use allow_other_host: true for trusted, explicitly whitelisted hosts.
          redirect_to(safe_uri, allow_other_host: is_trusted)
        else
          redirect_to(permalink_redirector.redirect_confirmation_path, allow_other_host: false)
        end
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

  private

  # Validate a redirect URI string and return [uri_str, trusted?] only if it's allowed, otherwise [nil, false].
  # Trusted means whitelisted in config ENV or matching our own host exactly.
  def safe_redirect_uri_and_trust_status(uri_str)
    return [nil, false] if uri_str.blank?

    begin
      uri = URI.parse(uri_str)
    rescue URI::InvalidURIError
      return [nil, false]
    end

    return [nil, false] unless uri.scheme&.downcase.in?(%w[http https])
    return [nil, false] if uri.host.blank?

    host = uri.host.downcase
    current_host = request.host.downcase

    # Build whitelist from ENV, exact host match only
    allowed = ENV.fetch('ALLOWED_REDIRECT_HOSTS', '')
                .split(',')
                .map(&:strip)
                .reject(&:empty?)
                .map(&:downcase)
    allowed << current_host unless allowed.include?(current_host)

    if allowed.include?(host)
      # Trusted host (either self or in explicit whitelist)
      [uri_str, host != current_host] # `allow_other_host: true` only when host is not ours but whitelisted
    elsif host == current_host
      [uri_str, false] # always safe, don't allow_other_host for own host
    else
      [nil, false]
    end
  end
end

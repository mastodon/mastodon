# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Localized
  include UserTrackingConcern
  include SessionTrackingConcern
  include CacheConcern
  include PreloadingConcern
  include DomainControlHelper
  include DatabaseHelper
  include AuthorizedFetchHelper
  include SelfDestructHelper

  helper_method :current_account
  helper_method :current_session
  helper_method :single_user_mode?
  helper_method :use_seamless_external_login?
  helper_method :sso_account_settings
  helper_method :limited_federation_mode?
  helper_method :skip_csrf_meta_tags?

  rescue_from ActionController::ParameterMissing, Paperclip::AdapterRegistry::NoHandlerError, with: :bad_request
  rescue_from Mastodon::NotPermittedError, with: :forbidden
  rescue_from ActionController::RoutingError, ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::UnknownFormat, with: :not_acceptable
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_content
  rescue_from Mastodon::RateLimitExceededError, with: :too_many_requests

  rescue_from(*Mastodon::HTTP_CONNECTION_ERRORS, with: :internal_server_error)
  rescue_from Mastodon::RaceConditionError, Stoplight::Error::RedLight, ActiveRecord::SerializationFailure, with: :service_unavailable

  rescue_from Seahorse::Client::NetworkingError do |e|
    Rails.logger.warn "Storage server error: #{e}"
    service_unavailable
  end

  before_action :check_self_destruct!

  before_action :store_referrer, except: :raise_not_found, if: :devise_controller?
  before_action :require_functional!, if: :user_signed_in?

  before_action :set_cache_control_defaults

  skip_before_action :verify_authenticity_token, only: :raise_not_found

  def raise_not_found
    raise ActionController::RoutingError, "No route matches #{params[:unmatched_route]}"
  end

  private

  def public_fetch_mode?
    !authorized_fetch_mode?
  end

  def store_referrer
    return if request.referer.blank?

    redirect_uri = URI(request.referer)
    return if redirect_uri.path.start_with?('/auth', '/settings/two_factor_authentication', '/settings/otp_authentication')

    stored_url = redirect_uri.to_s if redirect_uri.host == request.host && redirect_uri.port == request.port

    store_location_for(:user, stored_url)
  end

  def mfa_setup_path(path_params = {})
    settings_two_factor_authentication_methods_path(path_params)
  end

  def require_functional!
    return if current_user.functional?

    respond_to do |format|
      format.any do
        if current_user.missing_2fa?
          redirect_to mfa_setup_path
        elsif current_user.confirmed?
          redirect_to edit_user_registration_path
        else
          redirect_to auth_setup_path
        end
      end

      format.json do
        if !current_user.confirmed?
          render json: { error: 'Your login is missing a confirmed e-mail address' }, status: 403
        elsif !current_user.approved?
          render json: { error: 'Your login is currently pending approval' }, status: 403
        elsif current_user.missing_2fa?
          render json: { error: 'Your account requires two-factor authentication' }, status: 403
        elsif !current_user.functional?
          render json: { error: 'Your login is currently disabled' }, status: 403
        end
      end
    end
  end

  def skip_csrf_meta_tags?
    false
  end

  def after_sign_out_path_for(_resource_or_scope)
    if ENV['OMNIAUTH_ONLY'] == 'true' && Rails.configuration.x.omniauth.oidc_enabled?
      '/auth/auth/openid_connect/logout'
    else
      new_user_session_path
    end
  end

  protected

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(params[key])
  end

  def forbidden
    respond_with_error(403)
  end

  def not_found
    respond_with_error(404)
  end

  def gone
    respond_with_error(410)
  end

  def unprocessable_content
    respond_with_error(422)
  end

  def not_acceptable
    respond_with_error(406)
  end

  def bad_request
    respond_with_error(400)
  end

  def internal_server_error
    respond_with_error(500)
  end

  def service_unavailable
    respond_with_error(503)
  end

  def too_many_requests
    respond_with_error(429)
  end

  def single_user_mode?
    @single_user_mode ||= Rails.configuration.x.single_user_mode && Account.without_internal.exists?
  end

  def use_seamless_external_login?
    Devise.pam_authentication || Devise.ldap_authentication
  end

  def sso_account_settings
    ENV.fetch('SSO_ACCOUNT_SETTINGS', nil)
  end

  def current_account
    return @current_account if defined?(@current_account)

    @current_account = current_user&.account
  end

  def current_session
    return @current_session if defined?(@current_session)

    @current_session = SessionActivation.find_by(session_id: cookies.signed['_session_id']) if cookies.signed['_session_id'].present?
  end

  def respond_with_error(code)
    respond_to do |format|
      format.any  { render "errors/#{code}", layout: 'error', status: code, formats: [:html] }
      format.json { render json: { error: Rack::Utils::HTTP_STATUS_CODES[code] }, status: code }
    end
  end

  def check_self_destruct!
    return unless self_destruct?

    respond_to do |format|
      format.any  { render 'errors/self_destruct', layout: 'auth', status: 410, formats: [:html] }
      format.json { render json: { error: Rack::Utils::HTTP_STATUS_CODES[410] }, status: 410 }
    end
  end

  def set_cache_control_defaults
    response.cache_control.replace(private: true, no_store: true)
  end
end

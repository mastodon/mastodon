# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  force_ssl if: :https_enabled?

  include Localized
  include UserTrackingConcern
  include SessionTrackingConcern

  helper_method :current_account
  helper_method :current_session
  helper_method :current_theme
  helper_method :single_user_mode?
  helper_method :use_seamless_external_login?

  rescue_from ActionController::RoutingError, with: :not_found
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity
  rescue_from Mastodon::NotPermittedError, with: :forbidden

  before_action :store_current_location, except: :raise_not_found, unless: :devise_controller?
  before_action :check_suspension, if: :user_signed_in?

  def raise_not_found
    raise ActionController::RoutingError, "No route matches #{params[:unmatched_route]}"
  end

  private

  def https_enabled?
    Rails.env.production?
  end

  def store_current_location
    store_location_for(:user, request.url) unless request.format == :json
  end

  def require_admin!
    forbidden unless current_user&.admin?
  end

  def require_staff!
    forbidden unless current_user&.staff?
  end

  def check_suspension
    forbidden if current_user.account.suspended?
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  protected

  def forbidden
    respond_with_error(403)
  end

  def not_found
    respond_with_error(404)
  end

  def gone
    respond_with_error(410)
  end

  def unprocessable_entity
    respond_with_error(422)
  end

  def single_user_mode?
    @single_user_mode ||= Rails.configuration.x.single_user_mode && Account.exists?
  end

  def use_seamless_external_login?
    Devise.pam_authentication || Devise.ldap_authentication
  end

  def current_account
    @current_account ||= current_user.try(:account)
  end

  def current_session
    @current_session ||= SessionActivation.find_by(session_id: cookies.signed['_session_id'])
  end

  def current_theme
    return Setting.default_settings['theme'] unless Themes.instance.names.include? current_user&.setting_theme
    current_user.setting_theme
  end

  def cache_collection(raw, klass)
    return raw unless klass.respond_to?(:with_includes)

    raw                    = raw.cache_ids.to_a if raw.is_a?(ActiveRecord::Relation)
    uncached_ids           = []
    cached_keys_with_value = Rails.cache.read_multi(*raw.map(&:cache_key))

    raw.each do |item|
      uncached_ids << item.id unless cached_keys_with_value.key?(item.cache_key)
    end

    klass.reload_stale_associations!(cached_keys_with_value.values) if klass.respond_to?(:reload_stale_associations!)

    unless uncached_ids.empty?
      uncached = klass.where(id: uncached_ids).with_includes.map { |item| [item.id, item] }.to_h

      uncached.each_value do |item|
        Rails.cache.write(item.cache_key, item)
      end
    end

    raw.map { |item| cached_keys_with_value[item.cache_key] || uncached[item.id] }.compact
  end

  def respond_with_error(code)
    respond_to do |format|
      format.any  { head code }
      format.html do
        set_locale
        render "errors/#{code}", layout: 'error', status: code
      end
    end
  end

  def render_cached_json(cache_key, **options)
    options[:expires_in] ||= 3.minutes
    cache_key              = cache_key.join(':') if cache_key.is_a?(Enumerable)
    cache_public           = options.key?(:public) ? options.delete(:public) : true
    content_type           = options.delete(:content_type) || 'application/json'

    data = Rails.cache.fetch(cache_key, { raw: true }.merge(options)) do
      yield.to_json
    end

    expires_in options[:expires_in], public: cache_public
    render json: data, content_type: content_type
  end

  def set_cache_headers
    response.headers['Vary'] = 'Accept'
  end

  def skip_session!
    request.session_options[:skip] = true
  end
end

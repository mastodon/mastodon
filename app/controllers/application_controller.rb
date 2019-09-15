# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  force_ssl if: :https_enabled?

  include Localized
  include UserTrackingConcern
  include SessionTrackingConcern
  include CacheConcern
  include DomainControlHelper

  helper_method :current_account
  helper_method :current_session
  helper_method :current_flavour
  helper_method :current_skin
  helper_method :single_user_mode?
  helper_method :use_seamless_external_login?
  helper_method :whitelist_mode?

  rescue_from ActionController::RoutingError, with: :not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity
  rescue_from ActionController::UnknownFormat, with: :not_acceptable
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Mastodon::NotPermittedError, with: :forbidden
  rescue_from HTTP::Error, OpenSSL::SSL::SSLError, with: :internal_server_error
  rescue_from Mastodon::RaceConditionError, with: :service_unavailable

  before_action :store_current_location, except: :raise_not_found, unless: :devise_controller?
  before_action :require_functional!, if: :user_signed_in?

  skip_before_action :verify_authenticity_token, only: :raise_not_found

  def raise_not_found
    raise ActionController::RoutingError, "No route matches #{params[:unmatched_route]}"
  end

  private

  def https_enabled?
    Rails.env.production? && !request.path.start_with?('/health')
  end

  def authorized_fetch_mode?
    ENV['AUTHORIZED_FETCH'] == 'true' || Rails.configuration.x.whitelist_mode
  end

  def public_fetch_mode?
    !authorized_fetch_mode?
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

  def require_functional!
    redirect_to edit_user_registration_path unless current_user.functional?
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def pack(data, pack_name, skin = 'default')
    return nil unless pack?(data, pack_name)
    pack_data = {
      common: pack_name == 'common' ? nil : resolve_pack(data['name'] ? Themes.instance.flavour(current_flavour) : Themes.instance.core, 'common', skin),
      flavour: data['name'],
      pack: pack_name,
      preload: nil,
      skin: nil,
      supported_locales: data['locales'],
    }
    if data['pack'][pack_name].is_a?(Hash)
      pack_data[:common] = nil if data['pack'][pack_name]['use_common'] == false
      pack_data[:pack] = nil unless data['pack'][pack_name]['filename']
      if data['pack'][pack_name]['preload']
        pack_data[:preload] = [data['pack'][pack_name]['preload']] if data['pack'][pack_name]['preload'].is_a?(String)
        pack_data[:preload] = data['pack'][pack_name]['preload'] if data['pack'][pack_name]['preload'].is_a?(Array)
      end
      if skin != 'default' && data['skin'][skin]
        pack_data[:skin] = skin if data['skin'][skin].include?(pack_name)
      else  #  default skin
        pack_data[:skin] = 'default' if data['pack'][pack_name]['stylesheet']
      end
    end
    pack_data
  end

  def pack?(data, pack_name)
    if data['pack'].is_a?(Hash) && data['pack'].key?(pack_name)
      return true if data['pack'][pack_name].is_a?(String) || data['pack'][pack_name].is_a?(Hash)
    end
    false
  end

  def nil_pack(data, pack_name, skin = 'default')
    {
      common: pack_name == 'common' ? nil : resolve_pack(data['name'] ? Themes.instance.flavour(current_flavour) : Themes.instance.core, 'common', skin),
      flavour: data['name'],
      pack: nil,
      preload: nil,
      skin: nil,
      supported_locales: data['locales'],
    }
  end

  def resolve_pack(data, pack_name, skin = 'default')
    result = pack(data, pack_name, skin)
    unless result
      if data['name'] && data.key?('fallback')
        if data['fallback'].nil?
          return nil_pack(data, pack_name, skin)
        elsif data['fallback'].is_a?(String) && Themes.instance.flavour(data['fallback'])
          return resolve_pack(Themes.instance.flavour(data['fallback']), pack_name)
        elsif data['fallback'].is_a?(Array)
          data['fallback'].each do |fallback|
            return resolve_pack(Themes.instance.flavour(fallback), pack_name) if Themes.instance.flavour(fallback)
          end
        end
        return nil_pack(data, pack_name, skin)
      end
      return data.key?('name') && data['name'] != Setting.default_settings['flavour'] ? resolve_pack(Themes.instance.flavour(Setting.default_settings['flavour']), pack_name) : nil_pack(data, pack_name, skin)
    end
    result
  end

  def use_pack(pack_name)
    @core = resolve_pack(Themes.instance.core, pack_name)
    @theme = resolve_pack(Themes.instance.flavour(current_flavour), pack_name, current_skin)
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

  def unprocessable_entity
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

  def single_user_mode?
    @single_user_mode ||= Rails.configuration.x.single_user_mode && Account.where('id > 0').exists?
  end

  def use_seamless_external_login?
    Devise.pam_authentication || Devise.ldap_authentication
  end

  def current_account
    return @current_account if defined?(@current_account)

    @current_account = current_user&.account
  end

  def current_session
    return @current_session if defined?(@current_session)

    @current_session = SessionActivation.find_by(session_id: cookies.signed['_session_id']) if cookies.signed['_session_id'].present?
  end

  def current_flavour
    return Setting.flavour unless Themes.instance.flavours.include? current_user&.setting_flavour
    current_user.setting_flavour
  end

  def current_skin
    return Setting.skin unless Themes.instance.skins_for(current_flavour).include? current_user&.setting_skin
    current_user.setting_skin
  end

  def respond_with_error(code)
    respond_to do |format|
      format.any  { head code }

      format.html do
        use_pack 'error'
        render "errors/#{code}", layout: 'error', status: code
      end
    end
  end
end

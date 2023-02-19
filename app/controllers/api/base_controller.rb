# frozen_string_literal: true

class Api::BaseController < ApplicationController
  DEFAULT_STATUSES_LIMIT = 20
  DEFAULT_ACCOUNTS_LIMIT = 40

  include RateLimitHeaders
  include AccessTokenTrackingConcern

  skip_before_action :store_current_location
  skip_before_action :require_functional!, unless: :whitelist_mode?

  before_action :require_authenticated_user!, if: :disallow_unauthenticated_api_access?
  before_action :require_not_suspended!
  before_action :set_cache_headers

  protect_from_forgery with: :null_session

  content_security_policy do |p|
    # Set every directive that does not have a fallback
    p.default_src :none
    p.frame_ancestors :none
    p.form_action :none

    # Disable every directive with a fallback to cut on response size
    p.base_uri false
    p.font_src false
    p.img_src false
    p.style_src false
    p.media_src false
    p.frame_src false
    p.manifest_src false
    p.connect_src false
    p.script_src false
    p.child_src false
    p.worker_src false
  end

  rescue_from ActiveRecord::RecordInvalid, Mastodon::ValidationError do |e|
    render json: { error: e.to_s }, status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotUnique do
    render json: { error: 'Duplicate record' }, status: :unprocessable_entity
  end

  rescue_from Date::Error do
    render json: { error: 'Invalid date supplied' }, status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: 'Record not found' }, status: :not_found
  end

  rescue_from HTTP::Error, Mastodon::UnexpectedResponseError do
    render json: { error: 'Remote data could not be fetched' }, status: :service_unavailable
  end

  rescue_from OpenSSL::SSL::SSLError do
    render json: { error: 'Remote SSL certificate could not be verified' }, status: :service_unavailable
  end

  rescue_from Mastodon::NotPermittedError do
    render json: { error: 'This action is not allowed' }, status: :forbidden
  end

  rescue_from Seahorse::Client::NetworkingError do |e|
    Rails.logger.warn "Storage server error: #{e}"
    render json: { error: 'There was a temporary problem serving your request, please try again' }, status: :service_unavailable
  end

  rescue_from Mastodon::RaceConditionError, Stoplight::Error::RedLight do
    render json: { error: 'There was a temporary problem serving your request, please try again' }, status: :service_unavailable
  end

  rescue_from Mastodon::RateLimitExceededError do
    render json: { error: I18n.t('errors.429') }, status: :too_many_requests
  end

  rescue_from ActionController::ParameterMissing, Mastodon::InvalidParameterError do |e|
    render json: { error: e.to_s }, status: :bad_request
  end

  def doorkeeper_unauthorized_render_options(error: nil)
    { json: { error: (error.try(:description) || 'Not authorized') } }
  end

  def doorkeeper_forbidden_render_options(*)
    { json: { error: 'This action is outside the authorized scopes' } }
  end

  protected

  def set_pagination_headers(next_path = nil, prev_path = nil)
    links = []
    links << [next_path, [%w(rel next)]] if next_path
    links << [prev_path, [%w(rel prev)]] if prev_path
    response.headers['Link'] = LinkHeader.new(links) unless links.empty?
  end

  def limit_param(default_limit)
    return default_limit unless params[:limit]

    [params[:limit].to_i.abs, default_limit * 2].min
  end

  def params_slice(*keys)
    params.slice(*keys).permit(*keys)
  end

  def current_resource_owner
    @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_user
    current_resource_owner || super
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def require_authenticated_user!
    render json: { error: 'This method requires an authenticated user' }, status: :unauthorized unless current_user
  end

  def require_not_suspended!
    render json: { error: 'Your login is currently disabled' }, status: :forbidden if current_user&.account&.suspended?
  end

  def require_user!
    if !current_user
      render json: { error: 'This method requires an authenticated user' }, status: :unprocessable_entity
    elsif !current_user.confirmed?
      render json: { error: 'Your login is missing a confirmed e-mail address' }, status: :forbidden
    elsif !current_user.approved?
      render json: { error: 'Your login is currently pending approval' }, status: :forbidden
    elsif !current_user.functional?
      render json: { error: 'Your login is currently disabled' }, status: :forbidden
    else
      update_user_sign_in
    end
  end

  def render_empty
    render json: {}, status: :ok
  end

  def authorize_if_got_token!(*scopes)
    doorkeeper_authorize!(*scopes) if doorkeeper_token
  end

  def set_cache_headers
    response.headers['Cache-Control'] = 'private, no-store'
  end

  def disallow_unauthenticated_api_access?
    ENV['DISALLOW_UNAUTHENTICATED_API_ACCESS'] == 'true' || Rails.configuration.x.whitelist_mode
  end

  private

  def respond_with_error(code)
    render json: { error: Rack::Utils::HTTP_STATUS_CODES[code] }, status: code
  end
end

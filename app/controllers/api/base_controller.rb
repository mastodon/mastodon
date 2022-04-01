# frozen_string_literal: true

class Api::BaseController < ApplicationController
  DEFAULT_STATUSES_LIMIT = 20
  DEFAULT_ACCOUNTS_LIMIT = 40

  include RateLimitHeaders
  include AccessTokenTrackingConcern

  skip_before_action :store_current_location
  skip_before_action :require_functional!, unless: :whitelist_mode?

  before_action :require_authenticated_user!, if: :disallow_unauthenticated_api_access?
  before_action :set_cache_headers

  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordInvalid, Mastodon::ValidationError do |e|
    render json: { error: e.to_s }, status: 422
  end

  rescue_from ActiveRecord::RecordNotUnique do
    render json: { error: 'Duplicate record' }, status: 422
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: 'Record not found' }, status: 404
  end

  rescue_from HTTP::Error, Mastodon::UnexpectedResponseError do
    render json: { error: 'Remote data could not be fetched' }, status: 503
  end

  rescue_from OpenSSL::SSL::SSLError do
    render json: { error: 'Remote SSL certificate could not be verified' }, status: 503
  end

  rescue_from Mastodon::NotPermittedError do
    render json: { error: 'This action is not allowed' }, status: 403
  end

  rescue_from Seahorse::Client::NetworkingError do |e|
    Rails.logger.warn "Storage server error: #{e}"
    render json: { error: 'There was a temporary problem serving your request, please try again' }, status: 503
  end

  rescue_from Mastodon::RaceConditionError, Stoplight::Error::RedLight do
    render json: { error: 'There was a temporary problem serving your request, please try again' }, status: 503
  end

  rescue_from Mastodon::RateLimitExceededError do
    render json: { error: I18n.t('errors.429') }, status: 429
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: e.to_s }, status: 400
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
    render json: { error: 'This method requires an authenticated user' }, status: 401 unless current_user
  end

  def require_user!
    if !current_user
      render json: { error: 'This method requires an authenticated user' }, status: 422
    elsif !current_user.confirmed?
      render json: { error: 'Your login is missing a confirmed e-mail address' }, status: 403
    elsif !current_user.approved?
      render json: { error: 'Your login is currently pending approval' }, status: 403
    elsif !current_user.functional?
      render json: { error: 'Your login is currently disabled' }, status: 403
    else
      update_user_sign_in
    end
  end

  def render_empty
    render json: {}, status: 200
  end

  def authorize_if_got_token!(*scopes)
    doorkeeper_authorize!(*scopes) if doorkeeper_token
  end

  def set_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
  end

  def disallow_unauthenticated_api_access?
    authorized_fetch_mode?
  end
end

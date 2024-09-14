# frozen_string_literal: true

class Api::BaseController < ApplicationController
  DEFAULT_STATUSES_LIMIT = 20
  DEFAULT_ACCOUNTS_LIMIT = 40

  include Api::RateLimitHeaders
  include Api::AccessTokenTrackingConcern
  include Api::CachingConcern
  include Api::ContentSecurityPolicy
  include Api::ErrorHandling
  include Api::Pagination

  skip_before_action :require_functional!, unless: :limited_federation_mode?

  before_action :require_authenticated_user!, if: :disallow_unauthenticated_api_access?
  before_action :require_not_suspended!

  vary_by 'Authorization'

  protect_from_forgery with: :null_session

  def doorkeeper_unauthorized_render_options(error: nil)
    { json: { error: error.try(:description) || 'Not authorized' } }
  end

  def doorkeeper_forbidden_render_options(*)
    { json: { error: 'This action is outside the authorized scopes' } }
  end

  protected

  def limit_param(default_limit, max_limit = nil)
    return default_limit unless params[:limit]

    [params[:limit].to_i.abs, max_limit || (default_limit * 2)].min
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

  def require_not_suspended!
    render json: { error: 'Your login is currently disabled' }, status: 403 if current_user&.account&.unavailable?
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

  def disallow_unauthenticated_api_access?
    ENV['DISALLOW_UNAUTHENTICATED_API_ACCESS'] == 'true' || Rails.configuration.x.limited_federation_mode
  end

  private

  def respond_with_error(code)
    render json: { error: Rack::Utils::HTTP_STATUS_CODES[code] }, status: code
  end
end

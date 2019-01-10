# frozen_string_literal: true

class Api::BaseController < ApplicationController
  DEFAULT_STATUSES_LIMIT = 20
  DEFAULT_ACCOUNTS_LIMIT = 40

  include RateLimitHeaders

  skip_before_action :store_current_location
  skip_before_action :check_user_permissions

  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordInvalid, Mastodon::ValidationError do |e|
    render json: { error: e.to_s }, status: 422
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

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(params[key])
  end

  def current_resource_owner
    @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_user
    current_resource_owner || super
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def require_user!
    if current_user && !current_user.disabled?
      set_user_activity
    elsif current_user
      render json: { error: 'Your login is currently disabled' }, status: 403
    else
      render json: { error: 'This method requires an authenticated user' }, status: 422
    end
  end

  def render_empty
    render json: {}, status: 200
  end

  def authorize_if_got_token!(*scopes)
    doorkeeper_authorize!(*scopes) if doorkeeper_token
  end
end

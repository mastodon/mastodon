class ApiController < ApplicationController
  protect_from_forgery with: :null_session

  skip_before_action :verify_authenticity_token

  before_action :set_rate_limit_headers
  before_action :set_cors_headers

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: e.to_s }, status: 422
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: 'Record not found' }, status: 404
  end

  rescue_from Goldfinger::Error do
    render json: { error: 'Remote account could not be resolved' }, status: 422
  end

  rescue_from HTTP::Error do
    render json: { error: 'Remote data could not be fetched' }, status: 503
  end

  rescue_from OpenSSL::SSL::SSLError do
    render json: { error: 'Remote SSL certificate could not be verified' }, status: 503
  end

  def doorkeeper_unauthorized_render_options(*)
    { json: { error: 'Not authorized' } }
  end

  def doorkeeper_forbidden_render_options(*)
    { json: { error: 'This action is outside the authorized scopes' } }
  end

  protected

  def set_rate_limit_headers
    return if request.env['rack.attack.throttle_data'].nil?

    now        = Time.now.utc
    match_data = request.env['rack.attack.throttle_data']['api']

    response.headers['X-RateLimit-Limit']     = match_data[:limit].to_s
    response.headers['X-RateLimit-Remaining'] = (match_data[:limit] - match_data[:count]).to_s
    response.headers['X-RateLimit-Reset']     = (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
  end

  def set_cors_headers
    response.headers['Access-Control-Allow-Origin']   = '*'
    response.headers['Access-Control-Allow-Methods']  = 'POST, PUT, DELETE, GET, OPTIONS'
    response.headers['Access-Control-Request-Method'] = '*'
    response.headers['Access-Control-Allow-Headers']  = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_user
    super || current_resource_owner
  end

  def render_empty
    render json: {}, status: 200
  end

  def set_maps(statuses)
    status_ids      = statuses.flat_map { |s| [s.id, s.reblog_of_id] }.compact.uniq
    @reblogs_map    = Status.reblogs_map(status_ids, current_user.account)
    @favourites_map = Status.favourites_map(status_ids, current_user.account)
  end
end

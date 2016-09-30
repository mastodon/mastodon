class ApiController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

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

  protected

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_user
    super || current_resource_owner
  end

  def render_empty
    render json: {}, status: 200
  end
end

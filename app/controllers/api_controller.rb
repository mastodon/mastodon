class ApiController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordInvalid do
    render json: { error: 'Record invalid' }, status: 422
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: 'Record not found' }, status: 404
  end

  protected

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_user
    super || current_resource_owner
  end
end

class ApiController < ApplicationController
  protect_from_forgery with: :null_session

  protected

  def current_resource_owner
    User.find(doorkeeper_token.user_id) if doorkeeper_token
  end

  def current_user
    super || current_resource_owner
  end
end

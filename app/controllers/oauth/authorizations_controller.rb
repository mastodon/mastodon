class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  before_action :store_current_location

  private

  def store_current_location
    store_location_for(:user, request.url)
  end
end

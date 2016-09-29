class Api::V1::AppsController < ApiController
  respond_to :json

  def create
    @app = Doorkeeper::Application.create!(app_params)
  end

  private

  def app_params
    params.permit(:name, :redirect_uri)
  end
end

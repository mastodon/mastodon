class Api::V1::AppsController < ApiController
  respond_to :json

  def create
    @app = Doorkeeper::Application.create!(name: params[:client_name], redirect_uri: params[:redirect_uris])
  end
end

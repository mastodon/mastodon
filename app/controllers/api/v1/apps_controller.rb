# frozen_string_literal: true

class Api::V1::AppsController < ApiController
  respond_to :json

  def create
    @app = Doorkeeper::Application.create!(name: app_params[:client_name], redirect_uri: app_params[:redirect_uris], scopes: (app_params[:scopes] || Doorkeeper.configuration.default_scopes), website: app_params[:website])
  end

  private

  def app_params
    params.permit(:client_name, :redirect_uris, :scopes, :website)
  end
end

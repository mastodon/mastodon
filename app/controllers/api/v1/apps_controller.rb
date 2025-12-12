# frozen_string_literal: true

class Api::V1::AppsController < Api::BaseController
  skip_before_action :require_authenticated_user!
  before_action :validate_token_endpoint_auth_method!

  TOKEN_ENDPOINT_AUTH_METHODS = %w(none client_secret_basic client_secret_post).freeze

  def create
    @app = Doorkeeper::Application.create!(application_options)
    render json: @app, serializer: REST::CredentialApplicationSerializer
  end

  private

  def application_options
    {
      name: app_params[:client_name],
      redirect_uri: app_params[:redirect_uris],
      scopes: app_scopes_or_default,
      website: app_params[:website],
      confidential: !app_public?,
    }
  end

  def validate_token_endpoint_auth_method!
    return unless app_params.include? :token_endpoint_auth_method

    bad_request unless TOKEN_ENDPOINT_AUTH_METHODS.include? app_params[:token_endpoint_auth_method]
  end

  def app_public?
    app_params[:token_endpoint_auth_method] == 'none'
  end

  def app_scopes_or_default
    app_params[:scopes] || Doorkeeper.configuration.default_scopes
  end

  def app_params
    params.permit(:client_name, :scopes, :website, :token_endpoint_auth_method, :redirect_uris, redirect_uris: [])
  end
end

# frozen_string_literal: true

class OauthMetadataPresenter < ActiveModelSerializers::Model
  include RoutingHelper

  attributes :issuer, :authorization_endpoint, :token_endpoint,
             :revocation_endpoint, :scopes_supported,
             :response_types_supported, :response_modes_supported,
             :grant_types_supported, :token_endpoint_auth_methods_supported,
             :service_documentation, :app_registration_endpoint

  def issuer
    root_url
  end

  def service_documentation
    'https://docs.joinmastodon.org/'
  end

  def authorization_endpoint
    oauth_authorization_url
  end

  def token_endpoint
    oauth_token_url
  end

  # As the api_v1_apps route doesn't technically conform to the specification
  # for OAuth 2.0 Dynamic Client Registration defined in RFC 7591 we use a
  # non-standard property for now to indicate the mastodon specific registration
  # endpoint. See: https://datatracker.ietf.org/doc/html/rfc7591
  def app_registration_endpoint
    api_v1_apps_url
  end

  def revocation_endpoint
    oauth_revoke_url
  end

  def scopes_supported
    doorkeeper.scopes
  end

  def response_types_supported
    doorkeeper.authorization_response_types
  end

  def response_modes_supported
    doorkeeper.authorization_response_flows.flat_map(&:response_mode_matches).uniq
  end

  def grant_types_supported
    grant_types_supported = doorkeeper.grant_flows.dup
    grant_types_supported << 'refresh_token' if doorkeeper.refresh_token_enabled?
    grant_types_supported
  end

  def token_endpoint_auth_methods_supported
    %w(client_secret_basic client_secret_post)
  end

  private

  def doorkeeper
    @doorkeeper ||= Doorkeeper.configuration
  end
end

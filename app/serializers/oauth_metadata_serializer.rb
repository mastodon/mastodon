# frozen_string_literal: true

class OauthMetadataSerializer < ActiveModel::Serializer
  attributes :issuer, :authorization_endpoint, :token_endpoint,
             :registration_endpoint, :revocation_endpoint, :scopes_supported,
             :response_types_supported, :response_modes_supported,
             :grant_types_supported, :token_endpoint_auth_methods_supported
end

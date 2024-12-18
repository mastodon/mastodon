# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'The /.well-known/oauth-authorization-server request' do
  let(:protocol) { ENV.fetch('LOCAL_HTTPS', true) ? :https : :http }

  before do
    host! Rails.configuration.x.local_domain
  end

  it 'returns http success with valid JSON response' do
    get '/.well-known/oauth-authorization-server'

    expect(response)
      .to have_http_status(200)
      .and have_attributes(
        media_type: 'application/json'
      )

    grant_types_supported = Doorkeeper.configuration.grant_flows.dup
    grant_types_supported << 'refresh_token' if Doorkeeper.configuration.refresh_token_enabled?

    expect(response.parsed_body).to include(
      issuer: root_url(protocol: protocol),
      service_documentation: 'https://docs.joinmastodon.org/',
      authorization_endpoint: oauth_authorization_url(protocol: protocol),
      token_endpoint: oauth_token_url(protocol: protocol),
      revocation_endpoint: oauth_revoke_url(protocol: protocol),
      scopes_supported: Doorkeeper.configuration.scopes.map(&:to_s),
      response_types_supported: Doorkeeper.configuration.authorization_response_types,
      response_modes_supported: Doorkeeper.configuration.authorization_response_flows.flat_map(&:response_mode_matches).uniq,
      token_endpoint_auth_methods_supported: %w(client_secret_basic client_secret_post),
      grant_types_supported: grant_types_supported,
      code_challenge_methods_supported: ['S256'],
      # non-standard extension:
      app_registration_endpoint: api_v1_apps_url(protocol: protocol)
    )
  end
end

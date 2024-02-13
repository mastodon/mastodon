# frozen_string_literal: true

require 'rails_helper'

describe 'The /.well-known/oauth-authorization-server request' do
  it 'returns http success with valid JSON response' do
    get '/.well-known/oauth-authorization-server'

    expect(response)
      .to have_http_status(200)
      .and have_attributes(
        media_type: 'application/json'
      )

    expect(body_as_json).to match(
      a_hash_including(
        # FIXME: Include tests for the important URLs (for some reason routing
        # was generating mismatching URLs between the serializer and the tests)
        scopes_supported: Doorkeeper.configuration.scopes.map(&:to_s)
      )
    )
  end
end

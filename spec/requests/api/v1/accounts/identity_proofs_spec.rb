# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts Identity Proofs API' do
  include_context 'with API authentication', oauth_scopes: 'read:accounts'

  let(:account) { Fabricate(:account) }

  describe 'GET /api/v1/accounts/identity_proofs' do
    it 'returns http success' do
      get "/api/v1/accounts/#{account.id}/identity_proofs", params: { limit: 2 }, headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end
end

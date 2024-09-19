# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts Identity Proofs API' do
  let(:user)     { Fabricate(:user) }
  let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)   { 'read:accounts' }
  let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }
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

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts Lookup API' do
  let(:user)     { Fabricate(:user) }
  let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)   { 'read:accounts' }
  let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }
  let(:account) { Fabricate(:account) }

  describe 'GET /api/v1/accounts/lookup' do
    it 'returns http success' do
      get '/api/v1/accounts/lookup', params: { account_id: account.id, acct: account.acct }, headers: headers

      expect(response).to have_http_status(200)
    end
  end
end

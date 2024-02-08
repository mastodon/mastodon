# frozen_string_literal: true

require 'rails_helper'

describe 'Featured Tags Suggestions API' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:accounts' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:account) { Fabricate(:account) }

  describe 'GET /api/v1/featured_tags/suggestions' do
    it 'returns http success' do
      get '/api/v1/featured_tags/suggestions', params: { account_id: account.id, limit: 2 }, headers: headers

      expect(response).to have_http_status(200)
    end
  end
end

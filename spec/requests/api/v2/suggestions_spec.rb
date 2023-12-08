# frozen_string_literal: true

require 'rails_helper'

describe 'Suggestions API' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v2/suggestions' do
    it 'returns http success' do
      get '/api/v2/suggestions', headers: headers

      expect(response).to have_http_status(200)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 Direct Timeline' do
  let(:user) { Fabricate(:user) }
  let(:scopes)  { 'read:statuses' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/timelines/direct' do
    it 'returns 200' do
      get '/api/v1/timelines/direct', headers: headers

      expect(response).to have_http_status(200)
    end
  end
end

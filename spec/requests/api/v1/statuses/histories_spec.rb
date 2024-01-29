# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 Statuses Histories' do
  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:statuses' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  context 'with an oauth token' do
    describe 'GET /api/v1/statuses/:status_id/history' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        get "/api/v1/statuses/#{status.id}/history", headers: headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
        expect(body_as_json.size).to_not be 0
      end
    end
  end
end

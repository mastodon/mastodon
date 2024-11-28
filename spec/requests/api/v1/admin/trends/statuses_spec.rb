# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Admin Trends Statuses' do
  let(:role)   { UserRole.find_by(name: 'Admin') }
  let(:user)   { Fabricate(:user, role: role) }
  let(:scopes) { 'admin:read admin:write' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:account) { Fabricate(:account) }
  let(:status)  { Fabricate(:status) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/admin/trends/statuses' do
    it 'returns http success' do
      get '/api/v1/admin/trends/statuses', params: { account_id: account.id, limit: 2 }, headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end

  describe 'POST /api/v1/admin/trends/statuses/:id/approve' do
    before do
      post "/api/v1/admin/trends/statuses/#{status.id}/approve", headers: headers
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end

  describe 'POST /api/v1/admin/trends/statuses/:id/unapprove' do
    before do
      post "/api/v1/admin/trends/statuses/#{status.id}/reject", headers: headers
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Admin Trends Tags' do
  include_context 'with API authentication', user_fabricator: :admin_user, oauth_scopes: 'admin:read admin:write'

  let(:account) { Fabricate(:account) }
  let(:tag)     { Fabricate(:tag) }

  describe 'GET /api/v1/admin/trends/tags' do
    it 'returns http success' do
      get '/api/v1/admin/trends/tags', params: { account_id: account.id, limit: 2 }, headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end

  describe 'POST /api/v1/admin/trends/tags/:id/approve' do
    before do
      post "/api/v1/admin/trends/tags/#{tag.id}/approve", headers: headers
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end

  describe 'POST /api/v1/admin/trends/tags/:id/reject' do
    before do
      post "/api/v1/admin/trends/tags/#{tag.id}/reject", headers: headers
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

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Retention' do
  let(:user)    { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:account) { Fabricate(:account) }

  describe 'GET /api/v1/admin/retention' do
    context 'when not authorized' do
      it 'returns http forbidden' do
        post '/api/v1/admin/retention', params: { account_id: account.id, limit: 2 }

        expect(response)
          .to have_http_status(403)
      end
    end

    context 'with correct scope' do
      let(:scopes) { 'admin:read' }

      it 'returns http success and status json' do
        post '/api/v1/admin/retention', params: { account_id: account.id, limit: 2 }, headers: headers

        expect(response)
          .to have_http_status(200)

        expect(response.parsed_body)
          .to be_an(Array)
      end
    end
  end
end

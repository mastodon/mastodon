# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Policies' do
  let(:user)    { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:notifications write:notifications' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/notifications/policy', :sidekiq_inline do
    subject do
      get '/api/v1/notifications/policy', headers: headers, params: params
    end

    let(:params) { {} }

    before do
      Fabricate(:notification_request, account: user.account)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:notifications'

    context 'with no options' do
      it 'returns http success', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'PUT /api/v1/notifications/policy' do
    subject do
      put '/api/v1/notifications/policy', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end
  end
end

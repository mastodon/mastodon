# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Statuses Contexts' do
  context 'with an oauth token' do
    let(:user) { Fabricate(:user) }
    let(:client_app) { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, application: client_app, scopes: scopes) }
    let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

    describe 'GET /api/v1/statuses/:status_id/context' do
      let(:scopes) { 'read:statuses' }
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        Fabricate(:status, account: user.account, thread: status)
      end

      it 'returns http success' do
        get "/api/v1/statuses/#{status.id}/context", headers: headers

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  context 'without an oauth token' do
    context 'with a public status' do
      let(:status) { Fabricate(:status, visibility: :public) }

      describe 'GET /api/v1/statuses/:status_id/context' do
        before do
          Fabricate(:status, thread: status)
        end

        it 'returns http success' do
          get "/api/v1/statuses/#{status.id}/context"

          expect(response)
            .to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end
  end
end

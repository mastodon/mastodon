# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Requests' do
  let(:user)    { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:notifications write:notifications' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/notifications/requests', :inline_jobs do
    subject do
      get '/api/v1/notifications/requests', headers: headers, params: params
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
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/notifications/requests/:id/accept' do
    subject do
      post "/api/v1/notifications/requests/#{notification_request.id}/accept", headers: headers
    end

    let(:notification_request) { Fabricate(:notification_request, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'returns http success and creates notification permission' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(NotificationPermission.find_by(account: notification_request.account, from_account: notification_request.from_account)).to_not be_nil
    end

    context 'when notification request belongs to someone else' do
      let(:notification_request) { Fabricate(:notification_request) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/notifications/requests/:id/dismiss' do
    subject do
      post "/api/v1/notifications/requests/#{notification_request.id}/dismiss", headers: headers
    end

    let!(:notification_request) { Fabricate(:notification_request, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'returns http success and destroys the notification request', :aggregate_failures do
      expect { subject }.to change(NotificationRequest, :count).by(-1)

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end

    context 'when notification request belongs to someone else' do
      let(:notification_request) { Fabricate(:notification_request) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/notifications/requests/accept' do
    subject do
      post '/api/v1/notifications/requests/accept', params: { id: [notification_request.id] }, headers: headers
    end

    let!(:notification_request) { Fabricate(:notification_request, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'returns http success and creates notification permission', :aggregate_failures do
      subject

      expect(NotificationPermission.find_by(account: notification_request.account, from_account: notification_request.from_account)).to_not be_nil
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end

  describe 'POST /api/v1/notifications/requests/dismiss' do
    subject do
      post '/api/v1/notifications/requests/dismiss', params: { id: [notification_request.id] }, headers: headers
    end

    let!(:notification_request) { Fabricate(:notification_request, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'returns http success and destroys the notification request', :aggregate_failures do
      expect { subject }.to change(NotificationRequest, :count).by(-1)

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end

  describe 'GET /api/v1/notifications/requests/merged' do
    subject do
      get '/api/v1/notifications/requests/merged', headers: headers
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:notifications'

    context 'when the user has no accepted request pending merge' do
      it 'returns http success and returns merged: true' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to match({ merged: true })
      end
    end

    context 'when the user has an accepted request pending merge' do
      before do
        redis.set("notification_unfilter_jobs:#{user.account_id}", 1)
      end

      it 'returns http success and returns merged: false' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to match({ merged: false })
      end
    end
  end
end

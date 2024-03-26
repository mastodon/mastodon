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
      Fabricate(:notification_request, account: user.account, dismissed: true)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:notifications'

    context 'with no options' do
      it 'returns http success', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
      end
    end

    context 'with dismissed' do
      let(:params) { { dismissed: '1' } }

      it 'returns http success', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /api/v1/notifications/requests/:id/accept' do
    subject do
      post "/api/v1/notifications/requests/#{notification_request.id}/accept", headers: headers
    end

    let(:notification_request) { Fabricate(:notification_request, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'creates notification permission' do
      subject

      expect(NotificationPermission.find_by(account: notification_request.account, from_account: notification_request.from_account)).to_not be_nil
    end

    context 'when notification request belongs to someone else' do
      let(:notification_request) { Fabricate(:notification_request) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/notifications/requests/:id/dismiss' do
    subject do
      post "/api/v1/notifications/requests/#{notification_request.id}/dismiss", headers: headers
    end

    let(:notification_request) { Fabricate(:notification_request, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'returns http success and dismisses the notification request', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(notification_request.reload.dismissed?).to be true
    end

    context 'when notification request belongs to someone else' do
      let(:notification_request) { Fabricate(:notification_request) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end
end

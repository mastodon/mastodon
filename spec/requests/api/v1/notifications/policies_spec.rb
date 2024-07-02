# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Policies' do
  let(:user)    { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:notifications write:notifications' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/notifications/policy', :inline_jobs do
    subject do
      get '/api/v1/notifications/policy', headers: headers, params: params
    end

    let(:params) { {} }

    before do
      Fabricate(:notification_request, account: user.account)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:notifications'

    context 'with no options' do
      it 'returns json with expected attributes', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json).to include(
          filter_not_following: false,
          filter_not_followers: false,
          filter_new_accounts: false,
          filter_private_mentions: true,
          summary: a_hash_including(
            pending_requests_count: 1,
            pending_notifications_count: 0
          )
        )
      end
    end
  end

  describe 'PUT /api/v1/notifications/policy' do
    subject do
      put '/api/v1/notifications/policy', headers: headers, params: params
    end

    let(:params) { { filter_not_following: true } }

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'changes notification policy and returns an updated json object', :aggregate_failures do
      expect { subject }
        .to change { NotificationPolicy.find_or_initialize_by(account: user.account).filter_not_following }.from(false).to(true)

      expect(response).to have_http_status(200)
      expect(body_as_json).to include(
        filter_not_following: true,
        filter_not_followers: false,
        filter_new_accounts: false,
        filter_private_mentions: true,
        summary: a_hash_including(
          pending_requests_count: 0,
          pending_notifications_count: 0
        )
      )
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Policies' do
  let(:user)    { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:notifications write:notifications' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v2/notifications/policy', :inline_jobs do
    subject do
      get '/api/v2/notifications/policy', headers: headers, params: params
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
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to include(
          for_not_following: 'accept',
          for_not_followers: 'accept',
          for_new_accounts: 'accept',
          for_private_mentions: 'filter',
          for_limited_accounts: 'filter',
          summary: a_hash_including(
            pending_requests_count: 1,
            pending_notifications_count: 0
          )
        )
      end
    end
  end

  describe 'PUT /api/v2/notifications/policy' do
    subject do
      put '/api/v2/notifications/policy', headers: headers, params: params
    end

    let(:params) { { for_not_following: 'filter', for_limited_accounts: 'drop' } }

    it_behaves_like 'forbidden for wrong scope', 'read read:notifications'

    it 'changes notification policy and returns an updated json object', :aggregate_failures do
      expect { subject }
        .to change { NotificationPolicy.find_or_initialize_by(account: user.account).for_not_following.to_sym }.from(:accept).to(:filter)
        .and change { NotificationPolicy.find_or_initialize_by(account: user.account).for_limited_accounts.to_sym }.from(:filter).to(:drop)

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to include(
        for_not_following: 'filter',
        for_not_followers: 'accept',
        for_new_accounts: 'accept',
        for_private_mentions: 'filter',
        for_limited_accounts: 'drop',
        summary: a_hash_including(
          pending_requests_count: 0,
          pending_notifications_count: 0
        )
      )
    end
  end
end

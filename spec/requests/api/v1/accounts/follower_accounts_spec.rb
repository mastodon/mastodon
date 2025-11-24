# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Accounts FollowerAccounts' do
  include_context 'with API authentication', oauth_scopes: 'read:accounts'

  let(:account) { Fabricate(:account) }
  let(:alice)   { Fabricate(:account) }
  let(:bob)     { Fabricate(:account) }

  before do
    alice.follow!(account)
    bob.follow!(account)
  end

  describe 'GET /api/v1/accounts/:acount_id/followers' do
    it 'returns accounts following the given account', :aggregate_failures do
      get "/api/v1/accounts/#{account.id}/followers", params: { limit: 2 }, headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to contain_exactly(
          hash_including(id: alice.id.to_s),
          hash_including(id: bob.id.to_s)
        )
    end

    it 'does not return blocked users', :aggregate_failures do
      user.account.block!(bob)
      get "/api/v1/accounts/#{account.id}/followers", params: { limit: 2 }, headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to contain_exactly(
          hash_including(id: alice.id.to_s)
        )
    end

    context 'when requesting user is blocked' do
      before do
        account.block!(user.account)
      end

      it 'hides results' do
        get "/api/v1/accounts/#{account.id}/followers", params: { limit: 2 }, headers: headers
        expect(response.parsed_body.size).to eq 0
      end
    end

    context 'when requesting user is the account owner' do
      let(:user) { account.user }

      it 'returns all accounts, including muted accounts' do
        account.mute!(bob)
        get "/api/v1/accounts/#{account.id}/followers", params: { limit: 2 }, headers: headers

        expect(response.parsed_body)
          .to contain_exactly(
            hash_including(id: alice.id.to_s),
            hash_including(id: bob.id.to_s)
          )
      end
    end
  end
end

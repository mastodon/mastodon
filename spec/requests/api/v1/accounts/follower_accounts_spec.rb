# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 Accounts FollowerAccounts' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)   { 'read:accounts' }
  let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }
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
      expect(body_as_json.size).to eq 2
      expect([body_as_json[0][:id], body_as_json[1][:id]]).to contain_exactly(alice.id.to_s, bob.id.to_s)
    end

    it 'does not return blocked users', :aggregate_failures do
      user.account.block!(bob)
      get "/api/v1/accounts/#{account.id}/followers", params: { limit: 2 }, headers: headers

      expect(response).to have_http_status(200)
      expect(body_as_json.size).to eq 1
      expect(body_as_json[0][:id]).to eq alice.id.to_s
    end

    context 'when requesting user is blocked' do
      before do
        account.block!(user.account)
      end

      it 'hides results' do
        get "/api/v1/accounts/#{account.id}/followers", params: { limit: 2 }, headers: headers
        expect(body_as_json.size).to eq 0
      end
    end

    context 'when requesting user is the account owner' do
      let(:user) { account.user }

      it 'returns all accounts, including muted accounts' do
        account.mute!(bob)
        get "/api/v1/accounts/#{account.id}/followers", params: { limit: 2 }, headers: headers

        expect(body_as_json.size).to eq 2
        expect([body_as_json[0][:id], body_as_json[1][:id]]).to contain_exactly(alice.id.to_s, bob.id.to_s)
      end
    end
  end
end

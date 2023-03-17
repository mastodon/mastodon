# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Accounts::FollowingAccountsController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:accounts') }
  let(:account) { Fabricate(:account) }
  let(:alice)   { Fabricate(:account) }
  let(:bob)     { Fabricate(:account) }

  before do
    account.follow!(alice)
    account.follow!(bob)
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { account_id: account.id, limit: 2 }

      expect(response).to have_http_status(200)
    end

    it 'returns accounts followed by the given account' do
      get :index, params: { account_id: account.id, limit: 2 }

      expect(body_as_json.size).to eq 2
      expect([body_as_json[0][:id], body_as_json[1][:id]]).to contain_exactly(alice.id.to_s, bob.id.to_s)
    end

    it 'does not return blocked users' do
      user.account.block!(bob)
      get :index, params: { account_id: account.id, limit: 2 }

      expect(body_as_json.size).to eq 1
      expect(body_as_json[0][:id]).to eq alice.id.to_s
    end

    context 'when requesting user is blocked' do
      before do
        account.block!(user.account)
      end

      it 'hides results' do
        get :index, params: { account_id: account.id, limit: 2 }
        expect(body_as_json.size).to eq 0
      end
    end

    context 'when requesting user is the account owner' do
      let(:user) { account.user }

      it 'returns all accounts, including muted accounts' do
        account.mute!(bob)
        get :index, params: { account_id: account.id, limit: 2 }

        expect(body_as_json.size).to eq 2
        expect([body_as_json[0][:id], body_as_json[1][:id]]).to contain_exactly(alice.id.to_s, bob.id.to_s)
      end
    end
  end
end

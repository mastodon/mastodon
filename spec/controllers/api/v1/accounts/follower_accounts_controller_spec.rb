require 'rails_helper'

describe Api::V1::Accounts::FollowerAccountsController do
  render_views

  let(:user)    { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:accounts') }
  let(:account) { Fabricate(:account) }
  let(:alice)   { Fabricate(:account) }
  let(:bob)     { Fabricate(:account) }

  before do
    alice.follow!(account)
    bob.follow!(account)
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { account_id: account.id, limit: 2 }

      expect(response).to have_http_status(200)
    end

    it 'returns accounts following the given account' do
      get :index, params: { account_id: account.id, limit: 2 }

      expect(body_as_json.size).to eq 2
      expect([body_as_json[0][:id], body_as_json[1][:id]]).to match_array([alice.id.to_s, bob.id.to_s])
    end

    it 'does not return blocked users' do
      user.account.block!(bob)
      get :index, params: { account_id: account.id, limit: 2 }

      expect(body_as_json.size).to eq 1
      expect(body_as_json[0][:id]).to eq alice.id.to_s
    end
  end
end

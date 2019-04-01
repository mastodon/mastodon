require 'rails_helper'

describe Api::V1::Accounts::FollowingAccountsController do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:accounts') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:simon) { Fabricate(:account, username: 'simon') }
    let(:lewis) { Fabricate(:account, username: 'lewis') }

    before do
      lewis.follow!(simon)
    end

    it 'returns http success' do
      get :index, params: { account_id: lewis.id, limit: 1 }

      expect(response).to have_http_status(200)
    end

    it 'returns JSON with correct data' do
      get :index, params: { account_id: lewis.id, limit: 1 }

      json = body_as_json

      expect(json).to be_a Enumerable
      expect(json.first[:username]).to eq 'simon'
    end

    it 'does not return accounts blocking you' do
      simon.block!(user.account)
      get :index, params: { account_id: lewis.id, limit: 1 }

      json = body_as_json

      expect(json).to be_a Enumerable
      expect(json.size).to eq 0
    end
  end
end

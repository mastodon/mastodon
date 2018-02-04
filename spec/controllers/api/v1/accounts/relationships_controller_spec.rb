require 'rails_helper'

describe Api::V1::Accounts::RelationshipsController do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:simon) { Fabricate(:user, email: 'simon@example.com', account: Fabricate(:account, username: 'simon')).account }
    let(:lewis) { Fabricate(:user, email: 'lewis@example.com', account: Fabricate(:account, username: 'lewis')).account }

    before do
      user.account.follow!(simon)
      lewis.follow!(user.account)
    end

    context 'provided only one ID' do
      before do
        get :index, params: { id: simon.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns JSON with correct data' do
        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:following]).to be true
        expect(json.first[:followed_by]).to be false
      end
    end

    context 'provided multiple IDs' do
      before do
        get :index, params: { id: [simon.id, lewis.id] }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns JSON with correct data' do
        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:id]).to be simon.id
        expect(json.first[:following]).to be true
        expect(json.first[:followed_by]).to be false
        expect(json.first[:muting]).to be false
        expect(json.first[:requested]).to be false
        expect(json.first[:domain_blocking]).to be false

        expect(json.second[:id]).to be lewis.id
        expect(json.second[:following]).to be false
        expect(json.second[:followed_by]).to be true
        expect(json.second[:muting]).to be false
        expect(json.second[:requested]).to be false
        expect(json.second[:domain_blocking]).to be false
      end
    end
  end
end

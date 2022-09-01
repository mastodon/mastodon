require 'rails_helper'

describe Api::V1::Groups::RelationshipsController do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:groups') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:group1) { Fabricate(:group) }
    let(:group2) { Fabricate(:group) }

    before do
      group1.memberships.create!(account: user.account)
      group2.membership_requests.create!(account: user.account)
    end

    context 'provided only one ID' do
      before do
        get :index, params: { id: group1.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns JSON with correct data' do
        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:member]).to be true
        expect(json.first[:requested]).to be false
        expect(json.first[:role]).to eq 'user'
      end
    end

    context 'provided multiple IDs' do
      before do
        get :index, params: { id: [group1.id, group2.id] }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns JSON with correct data' do
        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:id]).to eq group1.id.to_s
        expect(json.first[:member]).to be true
        expect(json.first[:requested]).to be false
        expect(json.first[:role]).to eq 'user'

        expect(json.second[:id]).to eq group2.id.to_s
        expect(json.second[:member]).to be false
        expect(json.second[:requested]).to be true
        expect(json.second[:role]).to be_nil
      end

      it 'returns JSON with correct data on cached requests too' do
        get :index, params: { id: [group1.id] }

        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:member]).to be true
        expect(json.first[:requested]).to be false
        expect(json.first[:role]).to eq 'user'
      end

      it 'returns JSON with correct data after change too' do
        group1.memberships.where(account: user.account).destroy_all

        get :index, params: { id: [group1.id] }

        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:member]).to be false
        expect(json.first[:requested]).to be false
        expect(json.first[:role]).to be_nil
      end
    end
  end
end

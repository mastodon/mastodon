require 'rails_helper'

describe Api::V1::Groups::MembershipsController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:groups') }
  let(:group)   { Fabricate(:group) }
  let(:alice)   { Fabricate(:account) }
  let(:bob)     { Fabricate(:account) }

  before do
    group.memberships.create!(account: alice, role: :admin)
    group.memberships.create!(account: bob)
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { group_id: group.id, limit: 2 }

      expect(response).to have_http_status(200)
    end

    it 'returns memberships for the given group' do
      get :index, params: { group_id: group.id, limit: 2 }

      expect(body_as_json.size).to eq 2
      expect(body_as_json.map { |item| item[:account][:id] }).to match_array([alice.id.to_s, bob.id.to_s])
    end

    it 'does not return blocked users' do
      user.account.block!(bob)
      get :index, params: { group_id: group.id, limit: 2 }

      expect(body_as_json.size).to eq 1
      expect(body_as_json[0][:account][:id]).to eq alice.id.to_s
    end

    it 'filters by role' do
      get :index, params: { group_id: group.id, limit: 2, role: 'admin' }

      expect(body_as_json.size).to eq 1
      expect(body_as_json.map { |item| item[:account][:id] }).to match_array([alice.id.to_s])
    end
  end
end

require 'rails_helper'

RSpec.describe Api::V1::GroupsController, type: :controller do
  render_views

  let!(:user)  { Fabricate(:user) }
  let!(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let!(:group) { Fabricate(:group) }
  let!(:group_membership) { Fabricate(:group_membership, group: group, account: user.account) }
  let!(:other_group) { Fabricate(:group) }

  before { allow(controller).to receive(:doorkeeper_token) { token } }

  describe 'GET #index' do
    let(:scopes) { 'read:groups' }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end

    it 'returns the expected group' do
      get :index
      expect(body_as_json.map { |item| item[:id] }).to eq [group.id.to_s]
    end
  end

  describe 'GET #show' do
    let(:scopes) { 'read:groups' }

    it 'returns http success' do
      get :show, params: { id: group.id }
      expect(response).to have_http_status(200)
    end
  end
end

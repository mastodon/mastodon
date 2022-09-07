require 'rails_helper'

describe Api::V1::Groups::BlocksController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read:groups' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:group)   { Fabricate(:group) }
  let(:alice)   { Fabricate(:account) }
  let(:bob)     { Fabricate(:account) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    let!(:blocks) do
      group1 = Fabricate(:group)
      group2 = Fabricate(:group)
      [alice, bob].map do |account|
        # Surround actual tested blocks by dummy ones to effectively test the
        # pagination logic.
        group1.account_blocks.create!(account: account)
        block = group.account_blocks.create!(account: account)
        group2.account_blocks.create!(account: account)
        block
      end
    end

    context 'when the user is not a group member' do
      it 'returns http forbidden' do
        get :show, params: { group_id: group.id, limit: 2 }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user has no special role within the group' do
      before do
        group.memberships.create!(account: user.account)
      end

      it 'returns http forbidden' do
        get :show, params: { group_id: group.id, limit: 2 }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user is a group admin' do
      before do
        group.memberships.create!(account: user.account, role: :admin)
      end

      it 'returns http success' do
        get :show, params: { group_id: group.id, limit: 2 }

        expect(response).to have_http_status(200)
      end

      it 'returns memberships for the given group' do
        get :show, params: { group_id: group.id, limit: 2 }

        expect(body_as_json.size).to eq 2
        expect(body_as_json.map { |x| x[:id] }).to match_array([alice.id.to_s, bob.id.to_s])
      end

      it 'sets pagination header for next path' do
        get :show, params: { group_id: group.id, limit: 1, since_id: blocks[0] }
        expect(response.headers['Link'].find_link(['rel', 'next']).href).to eq api_v1_group_blocks_url(group_id: group.id, limit: 1, max_id: blocks[1])
      end

      it 'sets pagination header for previous path' do
        get :show, params: { group_id: group.id }
        expect(response.headers['Link'].find_link(['rel', 'prev']).href).to eq api_v1_group_blocks_url(since_id: blocks[1])
      end
    end
  end

  describe 'POST #create' do
    let(:scopes) { 'write:groups' }

    context 'when the user is not a group member' do
      it 'returns http forbidden' do
        post :create, params: { group_id: group.id, account_ids: [alice.id, bob.id] }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user has no special role within the group' do
      before do
        group.memberships.create!(account: user.account)
      end

      it 'returns http forbidden' do
        post :create, params: { group_id: group.id, account_ids: [alice.id, bob.id] }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user is a group admin' do
      before do
        group.memberships.create!(account: user.account, role: :admin)
        group.memberships.create!(account: alice)
        group.membership_requests.create!(account: bob)
      end

      it 'returns http success' do
        post :create, params: { group_id: group.id, account_ids: [alice.id, bob.id] }

        expect(response).to have_http_status(200)
      end

      it 'kicks existing members' do
        post :create, params: { group_id: group.id, account_ids: [alice.id, bob.id] }

        expect(group.memberships.find_by(account: alice)).to be_nil
      end

      it 'close pending requests' do
        post :create, params: { group_id: group.id, account_ids: [alice.id, bob.id] }

        expect(group.membership_requests.find_by(account: alice)).to be_nil
      end

      it 'create blocks' do
        post :create, params: { group_id: group.id, account_ids: [alice.id, bob.id] }

        expect(group.account_blocks.pluck(:account_id)).to match_array([alice.id, bob.id])
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:scopes) { 'write:groups' }

    context 'when the user is not a group member' do
      it 'returns http forbidden' do
        delete :destroy, params: { group_id: group.id, account_ids: [alice.id, bob.id] }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user has no special role within the group' do
      before do
        group.memberships.create!(account: user.account)
      end

      it 'returns http forbidden' do
        post :create, params: { group_id: group.id, account_ids: [alice.id, bob.id] }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user is a group admin' do
      before do
        group.memberships.create!(account: user.account, role: :admin)
        group.account_blocks.create!(account: alice)
      end

      it 'returns http success' do
        delete :destroy, params: { group_id: group.id, account_ids: [alice.id, bob.id] }

        expect(response).to have_http_status(200)
      end

      it 'removes blocks' do
        delete :destroy, params: { group_id: group.id, account_ids: [alice.id, bob.id] }

        expect(group.account_blocks.pluck(:account_id)).to eq []
      end
    end
  end
end

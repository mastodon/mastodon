require 'rails_helper'

describe Api::V1::Groups::MembershipRequestsController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read:groups' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:group)   { Fabricate(:group) }
  let(:alice)   { Fabricate(:account) }
  let(:bob)     { Fabricate(:account) }

  let!(:requests) do
    group1 = Fabricate(:group)
    group2 = Fabricate(:group)
    [alice, bob].map do |account|
      # Surround actual tested requests by dummy ones to effectively test the
      # pagination logic.
      group1.membership_requests.create!(account: account)
      request = group.membership_requests.create!(account: account)
      group2.membership_requests.create!(account: account)
      request
    end
  end

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    context 'when the user is not a group member' do
      it 'returns http forbidden' do
        get :index, params: { group_id: group.id, limit: 2 }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user has no special role within the group' do
      before do
        group.memberships.create!(account: user.account)
      end

      it 'returns http forbidden' do
        get :index, params: { group_id: group.id, limit: 2 }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user is a group admin' do
      before do
        group.memberships.create!(account: user.account, role: :admin)
      end

      it 'returns http success' do
        get :index, params: { group_id: group.id, limit: 2 }

        expect(response).to have_http_status(200)
      end

      it 'returns memberships for the given group' do
        get :index, params: { group_id: group.id, limit: 2 }

        expect(body_as_json.size).to eq 2
        expect(body_as_json.map { |x| x[:id] }).to match_array([alice.id.to_s, bob.id.to_s])
      end

      it 'does not return blocked users' do
        user.account.block!(bob)
        get :index, params: { group_id: group.id, limit: 2 }

        expect(body_as_json.size).to eq 1
        expect(body_as_json[0][:id]).to eq alice.id.to_s
      end

      it 'sets pagination header for next path' do
        get :index, params: { group_id: group.id, limit: 1, since_id: requests[0] }
        expect(response.headers['Link'].find_link(['rel', 'next']).href).to eq api_v1_group_membership_requests_url(group_id: group.id, limit: 1, max_id: requests[1])
      end

      it 'sets pagination header for previous path' do
        get :index, params: { group_id: group.id }
        expect(response.headers['Link'].find_link(['rel', 'prev']).href).to eq api_v1_group_membership_requests_url(since_id: requests[1])
      end
    end
  end

  describe 'POST #reject' do
    let(:scopes) { 'write:groups' }

    context 'when the user is not a group member' do
      it 'returns http forbidden' do
        post :reject, params: { group_id: group.id, id: alice.id }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user has no special role within the group' do
      before do
        group.memberships.create!(account: user.account)
      end

      it 'returns http forbidden' do
        post :reject, params: { group_id: group.id, id: alice.id }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user is a group admin' do
      before do
        group.memberships.create!(account: user.account, role: :admin)
      end

      it 'returns http success' do
        post :reject, params: { group_id: group.id, id: alice.id }

        expect(response).to have_http_status(200)
      end

      it 'deletes the membership request' do
        post :reject, params: { group_id: group.id, id: alice.id }

        expect(group.membership_requests.find_by(account: alice)).to be_nil
      end

      it 'does not create a membership' do
        post :reject, params: { group_id: group.id, id: alice.id }

        expect(group.memberships.find_by(account: alice)).to be_nil
      end
    end
  end

  describe 'POST #accept' do
    let(:scopes) { 'write:groups' }

    context 'when the user is not a group member' do
      it 'returns http forbidden' do
        post :accept, params: { group_id: group.id, id: alice.id }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user has no special role within the group' do
      before do
        group.memberships.create!(account: user.account)
      end

      it 'returns http forbidden' do
        post :accept, params: { group_id: group.id, id: alice.id }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user is a group admin' do
      before do
        group.memberships.create!(account: user.account, role: :admin)
      end

      it 'returns http success' do
        post :accept, params: { group_id: group.id, id: alice.id }

        expect(response).to have_http_status(200)
      end

      it 'deletes the membership request' do
        post :accept, params: { group_id: group.id, id: alice.id }

        expect(group.membership_requests.find_by(account: alice)).to be_nil
      end

      it 'creates a membership' do
        post :accept, params: { group_id: group.id, id: alice.id }

        expect(group.memberships.find_by(account: alice)).to_not be_nil
      end
    end
  end
end

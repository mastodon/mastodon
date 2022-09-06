require 'rails_helper'

RSpec.describe Api::V1::GroupsController, type: :controller do
  render_views

  let!(:user)  { Fabricate(:user) }
  let!(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:locked) { false }
  let(:group)  { Fabricate(:group, locked: locked) }

  before { allow(controller).to receive(:doorkeeper_token) { token } }

  shared_examples 'forbidden for wrong scope' do |wrong_scope|
    let(:scopes) { wrong_scope }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  describe 'GET #index' do
    let!(:other_group) { Fabricate(:group) }
    let(:scopes) { 'read:groups' }

    before do
      group.memberships.create!(account: user.account, group: group)
    end

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
    let!(:other_group) { Fabricate(:group) }
    let(:scopes) { 'read:groups' }

    before do
      group.memberships.create!(account: user.account, group: group)
    end

    it 'returns http success' do
      get :show, params: { id: group.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #join' do
    let(:scopes) { 'write:groups' }

    context do
      before do
        post :join, params: { id: group.id }
      end

      context 'with unlocked group' do
        let(:locked) { false }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns JSON with member=true and requested=false' do
          json = body_as_json

          expect(json[:member]).to be true
          expect(json[:requested]).to be false
        end

        it 'creates a group membership' do
          expect(group.memberships.find_by(account_id: user.account.id)).to_not be_nil
        end

        it_behaves_like 'forbidden for wrong scope', 'read:groups'
      end

      context 'with locked group' do
        let(:locked) { true }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns JSON with member=false and requested=true' do
          json = body_as_json

          expect(json[:member]).to be false
          expect(json[:requested]).to be true
        end

        it 'does not create a group membership' do
          expect(group.memberships.find_by(account_id: user.account.id)).to be_nil
        end

        it 'creates a group membership request' do
          expect(group.membership_requests.find_by(account_id: user.account.id)).to_not be_nil
        end

        it_behaves_like 'forbidden for wrong scope', 'read:groups'
      end
    end
  end

  describe 'POST #leave' do
    let(:scopes) { 'write:groups' }

    before do
      group.memberships.create!(account: user.account, group: group)
      post :leave, params: { id: group.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes the following relation between user and target user' do
      expect(group.memberships.find_by(account_id: user.account.id)).to be_nil
    end

    it_behaves_like 'forbidden for wrong scope', 'read:groups'
  end

  describe 'POST #kick' do
    let(:scopes) { 'write:groups' }
    let(:membership) { Fabricate(:group_membership, group: group) }

    context 'when the user is not a group member' do
      it 'returns http forbidden' do
        post :kick, params: { id: group.id, account_ids: [membership.account.id] }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user has no special role within the group' do
      before do
        group.memberships.create!(account: user.account)
      end

      it 'returns http forbidden' do
        post :kick, params: { id: group.id, account_ids: [membership.account.id] }

        expect(response).to have_http_status(403)
      end
    end

    context 'when the user is a group admin' do
      before do
        group.memberships.create!(account: user.account, role: :admin)
      end

      it 'returns http success' do
        post :kick, params: { id: group.id, account_ids: [membership.account.id] }

        expect(response).to have_http_status(200)
      end

      it 'deletes the membership' do
        post :kick, params: { id: group.id, account_ids: [membership.account.id] }

        expect(group.memberships.find_by(account: membership.account)).to be_nil
      end
    end
  end
end

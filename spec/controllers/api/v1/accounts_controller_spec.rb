require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'follow read') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: user.account.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #follow' do
    let(:other_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob', locked: locked)).account }

    before do
      post :follow, params: { id: other_account.id }
    end

    context 'with unlocked account' do
      let(:locked) { false }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns JSON with following=true and requested=false' do
        json = body_as_json

        expect(json[:following]).to be true
        expect(json[:requested]).to be false
      end

      it 'creates a following relation between user and target user' do
        expect(user.account.following?(other_account)).to be true
      end
    end

    context 'with locked account' do
      let(:locked) { true }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns JSON with following=false and requested=true' do
        json = body_as_json

        expect(json[:following]).to be false
        expect(json[:requested]).to be true
      end

      it 'creates a follow request relation between user and target user' do
        expect(user.account.requested?(other_account)).to be true
      end
    end
  end

  describe 'POST #unfollow' do
    let(:other_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      user.account.follow!(other_account)
      post :unfollow, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes the following relation between user and target user' do
      expect(user.account.following?(other_account)).to be false
    end
  end

  describe 'POST #block' do
    let(:other_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      user.account.follow!(other_account)
      post :block, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes the following relation between user and target user' do
      expect(user.account.following?(other_account)).to be false
    end

    it 'creates a blocking relation' do
      expect(user.account.blocking?(other_account)).to be true
    end
  end

  describe 'POST #unblock' do
    let(:other_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      user.account.block!(other_account)
      post :unblock, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes the blocking relation between user and target user' do
      expect(user.account.blocking?(other_account)).to be false
    end
  end

  describe 'POST #mute' do
    let(:other_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      user.account.follow!(other_account)
      post :mute, params: {id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'does not remove the following relation between user and target user' do
      expect(user.account.following?(other_account)).to be true
    end

    it 'creates a muting relation' do
      expect(user.account.muting?(other_account)).to be true
    end
  end

  describe 'POST #unmute' do
    let(:other_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      user.account.mute!(other_account)
      post :unmute, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes the muting relation between user and target user' do
      expect(user.account.muting?(other_account)).to be false
    end
  end
end

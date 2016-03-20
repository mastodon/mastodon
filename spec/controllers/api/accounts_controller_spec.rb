require 'rails_helper'

RSpec.describe Api::AccountsController, type: :controller do
  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, id: user.account.id
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #statuses' do
    it 'returns http success' do
      get :statuses, id: user.account.id
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #followers' do
    it 'returns http success' do
      get :followers, id: user.account.id
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #following' do
    it 'returns http success' do
      get :following, id: user.account.id
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #follow' do
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      post :follow, id: other_account.id
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'creates a following relation between user and target user' do
      expect(user.account.following?(other_account)).to be true
    end
  end

  describe 'POST #unfollow' do
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(other_account)
      post :unfollow, id: other_account.id
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes the following relation between user and target user' do
      expect(user.account.following?(other_account)).to be false
    end
  end
end

require 'rails_helper'

RSpec.describe Api::V1::FollowRequestsController, type: :controller do
  render_views

  let(:user)     { Fabricate(:user, account: Fabricate(:account, username: 'alice', locked: true)) }
  let(:token)    { double acceptable?: true, resource_owner_id: user.id }
  let(:follower) { Fabricate(:account, username: 'bob') }

  before do
    FollowService.new.call(follower, user.account.acct)
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    before do
      get :index, params: { limit: 1 }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #authorize' do
    before do
      post :authorize, params: { id: follower.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'allows follower to follow' do
      expect(follower.following?(user.account)).to be true
    end
  end

  describe 'POST #reject' do
    before do
      post :reject, params: { id: follower.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes follow request' do
      expect(FollowRequest.where(target_account: user.account, account: follower).count).to eq 0
    end
  end
end

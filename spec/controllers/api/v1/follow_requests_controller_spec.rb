require 'rails_helper'

RSpec.describe Api::V1::FollowRequestsController, type: :controller do
  render_views

  let(:user)     { Fabricate(:user, account: Fabricate(:account, username: 'alice', locked: true)) }
  let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:follower) { Fabricate(:account, username: 'bob') }

  before do
    FollowService.new.call(follower, user.account)
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:scopes) { 'read:follows' }

    before do
      get :index, params: { limit: 1 }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #authorize' do
    let(:scopes) { 'write:follows' }

    before do
      post :authorize, params: { id: follower.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'allows follower to follow' do
      expect(follower.following?(user.account)).to be true
    end

    it 'returns JSON with followed_by=true' do
      json = body_as_json

      expect(json[:followed_by]).to be true
    end
  end

  describe 'POST #reject' do
    let(:scopes) { 'write:follows' }

    before do
      post :reject, params: { id: follower.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes follow request' do
      expect(FollowRequest.where(target_account: user.account, account: follower).count).to eq 0
    end

    it 'returns JSON with followed_by=false' do
      json = body_as_json

      expect(json[:followed_by]).to be false
    end
  end
end

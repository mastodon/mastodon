require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: user.account.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #verify_credentials' do
    it 'returns http success' do
      get :verify_credentials
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update_credentials' do
    describe 'with valid data' do
      before do
        avatar = File.read(Rails.root.join('app', 'assets', 'images', 'logo.png'))
        header = File.read(Rails.root.join('app', 'assets', 'images', 'mastodon-getting-started.png'))

        patch :update_credentials, params: {
          display_name: "Alice Isn't Dead",
          note: "Hi!\n\nToot toot!",
          avatar: "data:image/png;base64,#{Base64.encode64(avatar)}",
          header: "data:image/png;base64,#{Base64.encode64(header)}",
        }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'updates account info' do
        user.account.reload

        expect(user.account.display_name).to eq("Alice Isn't Dead")
        expect(user.account.note).to eq("Hi!\n\nToot toot!")
        expect(user.account.avatar).to exist
        expect(user.account.header).to exist
      end
    end

    describe 'with invalid data' do
      before do
        patch :update_credentials, params: { note: 'This is too long. ' * 10 }
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #statuses' do
    it 'returns http success' do
      get :statuses, params: { id: user.account.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #followers' do
    it 'returns http success' do
      get :followers, params: { id: user.account.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #following' do
    it 'returns http success' do
      get :following, params: { id: user.account.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #follow' do
    let(:other_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      post :follow, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'creates a following relation between user and target user' do
      expect(user.account.following?(other_account)).to be true
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

  describe 'GET #relationships' do
    let(:simon) { Fabricate(:user, email: 'simon@example.com', account: Fabricate(:account, username: 'simon')).account }
    let(:lewis) { Fabricate(:user, email: 'lewis@example.com', account: Fabricate(:account, username: 'lewis')).account }

    before do
      user.account.follow!(simon)
      lewis.follow!(user.account)
    end

    context 'provided only one ID' do
      before do
        get :relationships, params: { id: simon.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns JSON with correct data' do
        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:following]).to be true
        expect(json.first[:followed_by]).to be false
      end
    end

    context 'provided multiple IDs' do
      before do
        get :relationships, params: { id: [simon.id, lewis.id] }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      xit 'returns JSON with correct data' do
        # todo
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AccountsController do
  render_views

  let(:user)   { Fabricate(:user) }
  let(:scopes) { '' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  shared_examples 'forbidden for wrong scope' do |wrong_scope|
    let(:scopes) { wrong_scope }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  describe 'POST #create' do
    let(:app) { Fabricate(:application) }
    let(:token) { Doorkeeper::AccessToken.find_or_create_for(application: app, resource_owner: nil, scopes: 'read write', use_refresh_token: false) }
    let(:agreement) { nil }

    before do
      post :create, params: { username: 'test', password: '12345678', email: 'hello@world.tld', agreement: agreement }
    end

    context 'when given truthy agreement' do
      let(:agreement) { 'true' }

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns a new access token as JSON' do
        expect(body_as_json[:access_token]).to_not be_blank
      end

      it 'creates a user' do
        user = User.find_by(email: 'hello@world.tld')
        expect(user).to_not be_nil
        expect(user.created_by_application_id).to eq app.id
      end
    end

    context 'when given no agreement' do
      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'GET #show' do
    let(:scopes) { 'read:accounts' }

    before do
      get :show, params: { id: user.account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
  end

  describe 'POST #follow' do
    let(:scopes) { 'write:follows' }
    let(:other_account) { Fabricate(:account, username: 'bob', locked: locked) }

    context 'when posting to an other account' do
      before do
        post :follow, params: { id: other_account.id }
      end

      context 'with unlocked account' do
        let(:locked) { false }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns JSON with following=true and requested=false' do
          json = body_as_json

          expect(json[:following]).to be true
          expect(json[:requested]).to be false
        end

        it 'creates a following relation between user and target user' do
          expect(user.account.following?(other_account)).to be true
        end

        it_behaves_like 'forbidden for wrong scope', 'read:accounts'
      end

      context 'with locked account' do
        let(:locked) { true }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns JSON with following=false and requested=true' do
          json = body_as_json

          expect(json[:following]).to be false
          expect(json[:requested]).to be true
        end

        it 'creates a follow request relation between user and target user' do
          expect(user.account.requested?(other_account)).to be true
        end

        it_behaves_like 'forbidden for wrong scope', 'read:accounts'
      end
    end

    context 'when modifying follow options' do
      let(:locked) { false }

      before do
        user.account.follow!(other_account, reblogs: false, notify: false)
      end

      it 'changes reblogs option' do
        post :follow, params: { id: other_account.id, reblogs: true }

        json = body_as_json

        expect(json[:following]).to be true
        expect(json[:showing_reblogs]).to be true
        expect(json[:notifying]).to be false
      end

      it 'changes notify option' do
        post :follow, params: { id: other_account.id, notify: true }

        json = body_as_json

        expect(json[:following]).to be true
        expect(json[:showing_reblogs]).to be false
        expect(json[:notifying]).to be true
      end

      it 'changes languages option' do
        post :follow, params: { id: other_account.id, languages: %w(en es) }

        json = body_as_json

        expect(json[:following]).to be true
        expect(json[:showing_reblogs]).to be false
        expect(json[:notifying]).to be false
        expect(json[:languages]).to match_array %w(en es)
      end
    end
  end

  describe 'POST #unfollow' do
    let(:scopes) { 'write:follows' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(other_account)
      post :unfollow, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes the following relation between user and target user' do
      expect(user.account.following?(other_account)).to be false
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST #remove_from_followers' do
    let(:scopes) { 'write:follows' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      other_account.follow!(user.account)
      post :remove_from_followers, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes the followed relation between user and target user' do
      expect(user.account.followed_by?(other_account)).to be false
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST #block' do
    let(:scopes) { 'write:blocks' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(other_account)
      post :block, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes the following relation between user and target user' do
      expect(user.account.following?(other_account)).to be false
    end

    it 'creates a blocking relation' do
      expect(user.account.blocking?(other_account)).to be true
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST #unblock' do
    let(:scopes) { 'write:blocks' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.block!(other_account)
      post :unblock, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes the blocking relation between user and target user' do
      expect(user.account.blocking?(other_account)).to be false
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST #mute' do
    let(:scopes) { 'write:mutes' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(other_account)
      post :mute, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'does not remove the following relation between user and target user' do
      expect(user.account.following?(other_account)).to be true
    end

    it 'creates a muting relation' do
      expect(user.account.muting?(other_account)).to be true
    end

    it 'mutes notifications' do
      expect(user.account.muting_notifications?(other_account)).to be true
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST #mute with notifications set to false' do
    let(:scopes) { 'write:mutes' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(other_account)
      post :mute, params: { id: other_account.id, notifications: false }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'does not remove the following relation between user and target user' do
      expect(user.account.following?(other_account)).to be true
    end

    it 'creates a muting relation' do
      expect(user.account.muting?(other_account)).to be true
    end

    it 'does not mute notifications' do
      expect(user.account.muting_notifications?(other_account)).to be false
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST #mute with nonzero duration set' do
    let(:scopes) { 'write:mutes' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(other_account)
      post :mute, params: { id: other_account.id, duration: 300 }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'does not remove the following relation between user and target user' do
      expect(user.account.following?(other_account)).to be true
    end

    it 'creates a muting relation' do
      expect(user.account.muting?(other_account)).to be true
    end

    it 'mutes notifications' do
      expect(user.account.muting_notifications?(other_account)).to be true
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST #unmute' do
    let(:scopes) { 'write:mutes' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.mute!(other_account)
      post :unmute, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes the muting relation between user and target user' do
      expect(user.account.muting?(other_account)).to be false
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end
end

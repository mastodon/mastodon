# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/accounts' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { '' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/accounts?id[]=:id' do
    let(:account) { Fabricate(:account) }
    let(:other_account) { Fabricate(:account) }
    let(:scopes) { 'read:accounts' }

    it 'returns expected response' do
      get '/api/v1/accounts', headers: headers, params: { id: [account.id, other_account.id, 123_123] }

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to contain_exactly(
        hash_including(id: account.id.to_s),
        hash_including(id: other_account.id.to_s)
      )
    end
  end

  describe 'GET /api/v1/accounts/:id' do
    context 'when logged out' do
      let(:account) { Fabricate(:account) }

      it 'returns account entity as 200 OK', :aggregate_failures do
        get "/api/v1/accounts/#{account.id}"

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:id]).to eq(account.id.to_s)
      end
    end

    context 'when the account does not exist' do
      it 'returns http not found' do
        get '/api/v1/accounts/1'

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:error]).to eq('Record not found')
      end
    end

    context 'when logged in' do
      subject do
        get "/api/v1/accounts/#{account.id}", headers: headers
      end

      let(:account) { Fabricate(:account) }
      let(:scopes) { 'read:accounts' }

      it 'returns account entity as 200 OK', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:id]).to eq(account.id.to_s)
      end

      it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    end
  end

  describe 'POST /api/v1/accounts' do
    subject do
      post '/api/v1/accounts', headers: headers, params: { username: 'test', password: '12345678', email: 'hello@world.tld', agreement: agreement }
    end

    let(:client_app) { Fabricate(:application) }
    let(:token) { Doorkeeper::AccessToken.find_or_create_for(application: client_app, resource_owner: nil, scopes: 'read write', use_refresh_token: false) }
    let(:agreement) { nil }

    context 'when given truthy agreement' do
      let(:agreement) { 'true' }

      it 'creates a user', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:access_token]).to_not be_blank

        user = User.find_by(email: 'hello@world.tld')
        expect(user).to_not be_nil
        expect(user.created_by_application_id).to eq client_app.id
      end
    end

    context 'when given no agreement' do
      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/accounts/:id/follow' do
    let(:scopes) { 'write:follows' }
    let(:other_account) { Fabricate(:account, username: 'bob', locked: locked) }

    context 'when posting to an other account' do
      subject do
        post "/api/v1/accounts/#{other_account.id}/follow", headers: headers
      end

      context 'with unlocked account' do
        let(:locked) { false }

        it 'creates a following relation between user and target user', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to include(
              following: true,
              requested: false
            )

          expect(user.account.following?(other_account)).to be true
        end

        it_behaves_like 'forbidden for wrong scope', 'read:accounts'
      end

      context 'with locked account' do
        let(:locked) { true }

        it 'creates a follow request relation between user and target user', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to include(
              following: false,
              requested: true
            )

          expect(user.account.requested?(other_account)).to be true
        end

        it_behaves_like 'forbidden for wrong scope', 'read:accounts'
      end
    end

    context 'when user tries to follow their own account' do
      subject do
        post "/api/v1/accounts/#{other_account.id}/follow", headers: headers
      end

      let(:locked) { false }
      let(:other_account) { user.account }

      it 'returns http forbidden and error message' do
        subject

        error_msg = I18n.t('accounts.self_follow_error')

        expect(response).to have_http_status(403)
        expect(response.parsed_body[:error]).to eq(error_msg)
      end

      it_behaves_like 'forbidden for wrong scope', 'read:accounts'
    end

    context 'when modifying follow options' do
      let(:locked) { false }

      before do
        user.account.follow!(other_account, reblogs: false, notify: false)
      end

      it 'changes reblogs option' do
        post "/api/v1/accounts/#{other_account.id}/follow", headers: headers, params: { reblogs: true }

        expect(response.parsed_body).to include({
          following: true,
          showing_reblogs: true,
          notifying: false,
        })
      end

      it 'changes notify option' do
        post "/api/v1/accounts/#{other_account.id}/follow", headers: headers, params: { notify: true }

        expect(response.parsed_body).to include({
          following: true,
          showing_reblogs: false,
          notifying: true,
        })
      end

      it 'changes languages option' do
        post "/api/v1/accounts/#{other_account.id}/follow", headers: headers, params: { languages: %w(en es) }

        expect(response.parsed_body).to include({
          following: true,
          showing_reblogs: false,
          notifying: false,
          languages: match_array(%w(en es)),
        })
      end
    end
  end

  describe 'POST /api/v1/accounts/:id/unfollow' do
    subject do
      post "/api/v1/accounts/#{other_account.id}/unfollow", headers: headers
    end

    let(:scopes) { 'write:follows' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(other_account)
    end

    it 'removes the following relation between user and target user', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(user.account.following?(other_account)).to be false
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST /api/v1/accounts/:id/remove_from_followers' do
    subject do
      post "/api/v1/accounts/#{other_account.id}/remove_from_followers", headers: headers
    end

    let(:scopes) { 'write:follows' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      other_account.follow!(user.account)
    end

    it 'removes the followed relation between user and target user', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(user.account.followed_by?(other_account)).to be false
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST /api/v1/accounts/:id/block' do
    subject do
      post "/api/v1/accounts/#{other_account.id}/block", headers: headers
    end

    let(:scopes) { 'write:blocks' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(other_account)
    end

    it 'creates a blocking relation', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(user.account.following?(other_account)).to be false
      expect(user.account.blocking?(other_account)).to be true
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST /api/v1/accounts/:id/unblock' do
    subject do
      post "/api/v1/accounts/#{other_account.id}/unblock", headers: headers
    end

    let(:scopes) { 'write:blocks' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.block!(other_account)
    end

    it 'removes the blocking relation between user and target user', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(user.account.blocking?(other_account)).to be false
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST /api/v1/accounts/:id/mute' do
    subject do
      post "/api/v1/accounts/#{other_account.id}/mute", headers: headers
    end

    let(:scopes) { 'write:mutes' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(other_account)
    end

    it 'mutes notifications', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(user.account.following?(other_account)).to be true
      expect(user.account.muting?(other_account)).to be true
      expect(user.account.muting_notifications?(other_account)).to be true
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST /api/v1/accounts/:id/mute with notifications set to false' do
    subject do
      post "/api/v1/accounts/#{other_account.id}/mute", headers: headers, params: { notifications: false }
    end

    let(:scopes) { 'write:mutes' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(other_account)
    end

    it 'does not mute notifications', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(user.account.following?(other_account)).to be true
      expect(user.account.muting?(other_account)).to be true
      expect(user.account.muting_notifications?(other_account)).to be false
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST /api/v1/accounts/:id/mute with nonzero duration set' do
    subject do
      post "/api/v1/accounts/#{other_account.id}/mute", headers: headers, params: { duration: 300 }
    end

    let(:scopes) { 'write:mutes' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(other_account)
    end

    it 'mutes notifications', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(user.account.following?(other_account)).to be true
      expect(user.account.muting?(other_account)).to be true
      expect(user.account.muting_notifications?(other_account)).to be true
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end

  describe 'POST /api/v1/accounts/:id/unmute' do
    subject do
      post "/api/v1/accounts/#{other_account.id}/unmute", headers: headers
    end

    let(:scopes) { 'write:mutes' }
    let(:other_account) { Fabricate(:account, username: 'bob') }

    before do
      user.account.mute!(other_account)
    end

    it 'removes the muting relation between user and target user', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(user.account.muting?(other_account)).to be false
    end

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
  end
end

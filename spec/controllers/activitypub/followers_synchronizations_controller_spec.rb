# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FollowersSynchronizationsController, type: :controller do
  let!(:account)    { Fabricate(:account) }
  let!(:follower_1) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/users/a') }
  let!(:follower_2) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/users/b') }
  let!(:follower_3) { Fabricate(:account, domain: 'foo.com', uri: 'https://foo.com/users/a') }
  let!(:follower_4) { Fabricate(:account, username: 'instance-actor', domain: 'example.com', uri: 'https://example.com') }

  before do
    follower_1.follow!(account)
    follower_2.follow!(account)
    follower_3.follow!(account)
    follower_4.follow!(account)
  end

  before do
    allow(controller).to receive(:signed_request_actor).and_return(remote_account)
  end

  describe 'GET #show' do
    context 'without signature' do
      let(:remote_account) { nil }

      before do
        get :show, params: { account_username: account.username }
      end

      it 'returns http not authorized' do
        expect(response).to have_http_status(401)
      end
    end

    context 'with signature from example.com' do
      subject(:body) { body_as_json }

      subject(:response) { get :show, params: { account_username: account.username } }

      let(:remote_account) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/instance') }

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns application/activity+json' do
        expect(response.media_type).to eq 'application/activity+json'
      end

      it 'returns orderedItems with followers from example.com' do
        expect(body[:orderedItems]).to be_an Array
        expect(body[:orderedItems]).to contain_exactly(follower_4.uri, follower_1.uri, follower_2.uri)
      end

      it 'returns private Cache-Control header' do
        expect(response.headers['Cache-Control']).to eq 'max-age=0, private'
      end

      context 'when account is permanently suspended' do
        before do
          account.suspend!
          account.deletion_request.destroy
        end

        it 'returns http gone' do
          expect(response).to have_http_status(410)
        end
      end

      context 'when account is temporarily suspended' do
        before do
          account.suspend!
        end

        it 'returns http forbidden' do
          expect(response).to have_http_status(403)
        end
      end
    end
  end
end

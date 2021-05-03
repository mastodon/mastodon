require 'rails_helper'

RSpec.describe ActivityPub::OutboxesController, type: :controller do
  let!(:account) { Fabricate(:account) }

  before do
    Fabricate(:status, account: account, visibility: :public)
    Fabricate(:status, account: account, visibility: :unlisted)
    Fabricate(:status, account: account, visibility: :private)
    Fabricate(:status, account: account, visibility: :direct)
    Fabricate(:status, account: account, visibility: :limited)
  end

  before do
    allow(controller).to receive(:signed_request_account).and_return(remote_account)
  end

  describe 'GET #show' do
    context 'without signature' do
      let(:remote_account) { nil }

      before do
        get :show, params: { account_username: account.username, page: page }
      end

      context 'with page not requested' do
        let(:page) { nil }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.content_type).to eq 'application/activity+json'
        end

        it 'returns totalItems' do
          json = body_as_json
          expect(json[:totalItems]).to eq 4
        end

        it 'returns public Cache-Control header' do
          expect(response.headers['Cache-Control']).to include 'public'
        end
      end

      context 'with page requested' do
        let(:page) { 'true' }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.content_type).to eq 'application/activity+json'
        end

        it 'returns orderedItems with public or unlisted statuses' do
          json = body_as_json
          expect(json[:orderedItems]).to be_an Array
          expect(json[:orderedItems].size).to eq 2
          expect(json[:orderedItems].all? { |item| item[:to].include?(ActivityPub::TagManager::COLLECTIONS[:public]) || item[:cc].include?(ActivityPub::TagManager::COLLECTIONS[:public]) }).to be true
        end

        it 'returns public Cache-Control header' do
          expect(response.headers['Cache-Control']).to include 'public'
        end
      end
    end

    context 'with signature' do
      let(:remote_account) { Fabricate(:account, domain: 'example.com') }
      let(:page) { 'true' }

      context 'when signed request account does not follow account' do
        before do
          get :show, params: { account_username: account.username, page: page }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.content_type).to eq 'application/activity+json'
        end

        it 'returns orderedItems with public or unlisted statuses' do
          json = body_as_json
          expect(json[:orderedItems]).to be_an Array
          expect(json[:orderedItems].size).to eq 2
          expect(json[:orderedItems].all? { |item| item[:to].include?(ActivityPub::TagManager::COLLECTIONS[:public]) || item[:cc].include?(ActivityPub::TagManager::COLLECTIONS[:public]) }).to be true
        end

        it 'returns private Cache-Control header' do
          expect(response.headers['Cache-Control']).to eq 'max-age=0, private'
        end
      end

      context 'when signed request account follows account' do
        before do
          remote_account.follow!(account)
          get :show, params: { account_username: account.username, page: page }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.content_type).to eq 'application/activity+json'
        end

        it 'returns orderedItems with private statuses' do
          json = body_as_json
          expect(json[:orderedItems]).to be_an Array
          expect(json[:orderedItems].size).to eq 3
          expect(json[:orderedItems].all? { |item| item[:to].include?(ActivityPub::TagManager::COLLECTIONS[:public]) || item[:cc].include?(ActivityPub::TagManager::COLLECTIONS[:public]) || item[:to].include?(account_followers_url(account, ActionMailer::Base.default_url_options)) }).to be true
        end

        it 'returns private Cache-Control header' do
          expect(response.headers['Cache-Control']).to eq 'max-age=0, private'
        end
      end

      context 'when signed request account is blocked' do
        before do
          account.block!(remote_account)
          get :show, params: { account_username: account.username, page: page }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.content_type).to eq 'application/activity+json'
        end

        it 'returns empty orderedItems' do
          json = body_as_json
          expect(json[:orderedItems]).to be_an Array
          expect(json[:orderedItems].size).to eq 0
        end

        it 'returns private Cache-Control header' do
          expect(response.headers['Cache-Control']).to eq 'max-age=0, private'
        end
      end

      context 'when signed request account is domain blocked' do
        before do
          account.block_domain!(remote_account.domain)
          get :show, params: { account_username: account.username, page: page }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.content_type).to eq 'application/activity+json'
        end

        it 'returns empty orderedItems' do
          json = body_as_json
          expect(json[:orderedItems]).to be_an Array
          expect(json[:orderedItems].size).to eq 0
        end

        it 'returns private Cache-Control header' do
          expect(response.headers['Cache-Control']).to eq 'max-age=0, private'
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::OutboxesController do
  let!(:account) { Fabricate(:account) }

  before do
    Fabricate(:status, account: account, visibility: :public)
    Fabricate(:status, account: account, visibility: :unlisted)
    Fabricate(:status, account: account, visibility: :private)
    Fabricate(:status, account: account, visibility: :direct)
    Fabricate(:status, account: account, visibility: :limited)

    allow(controller).to receive(:signed_request_actor).and_return(remote_account)
  end

  describe 'GET #show' do
    context 'without signature' do
      subject(:response) { get :show, params: { account_username: account.username, page: page } }

      let(:body) { body_as_json }
      let(:remote_account) { nil }

      context 'with page not requested' do
        let(:page) { nil }

        it_behaves_like 'cacheable response'

        it 'returns http success and correct media type and headers and items count' do
          expect(response).to have_http_status(200)
          expect(response.media_type).to eq 'application/activity+json'
          expect(response.headers['Vary']).to be_nil
          expect(body[:totalItems]).to eq 4
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

      context 'with page requested' do
        let(:page) { 'true' }

        it_behaves_like 'cacheable response'

        it 'returns http success and correct media type and vary header and items' do
          expect(response).to have_http_status(200)
          expect(response.media_type).to eq 'application/activity+json'
          expect(response.headers['Vary']).to include 'Signature'

          expect(body[:orderedItems]).to be_an Array
          expect(body[:orderedItems].size).to eq 2
          expect(body[:orderedItems].all? { |item| targets_public_collection?(item) }).to be true
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

    context 'with signature' do
      let(:remote_account) { Fabricate(:account, domain: 'example.com') }
      let(:page) { 'true' }

      context 'when signed request account does not follow account' do
        before do
          get :show, params: { account_username: account.username, page: page }
        end

        it 'returns http success and correct media type and headers and items' do
          expect(response).to have_http_status(200)
          expect(response.media_type).to eq 'application/activity+json'
          expect(response.headers['Cache-Control']).to eq 'max-age=60, private'

          expect(body_as_json[:orderedItems]).to be_an Array
          expect(body_as_json[:orderedItems].size).to eq 2
          expect(body_as_json[:orderedItems].all? { |item| targets_public_collection?(item) }).to be true
        end
      end

      context 'when signed request account follows account' do
        before do
          remote_account.follow!(account)
          get :show, params: { account_username: account.username, page: page }
        end

        it 'returns http success and correct media type and headers and items' do
          expect(response).to have_http_status(200)
          expect(response.media_type).to eq 'application/activity+json'
          expect(response.headers['Cache-Control']).to eq 'max-age=60, private'

          expect(body_as_json[:orderedItems]).to be_an Array
          expect(body_as_json[:orderedItems].size).to eq 3
          expect(body_as_json[:orderedItems].all? { |item| targets_public_collection?(item) || targets_followers_collection?(item, account) }).to be true
        end
      end

      context 'when signed request account is blocked' do
        before do
          account.block!(remote_account)
          get :show, params: { account_username: account.username, page: page }
        end

        it 'returns http success and correct media type and headers and items' do
          expect(response).to have_http_status(200)
          expect(response.media_type).to eq 'application/activity+json'
          expect(response.headers['Cache-Control']).to eq 'max-age=60, private'

          expect(body_as_json[:orderedItems])
            .to be_an(Array)
            .and be_empty
        end
      end

      context 'when signed request account is domain blocked' do
        before do
          account.block_domain!(remote_account.domain)
          get :show, params: { account_username: account.username, page: page }
        end

        it 'returns http success and correct media type and headers and items' do
          expect(response).to have_http_status(200)
          expect(response.media_type).to eq 'application/activity+json'
          expect(response.headers['Cache-Control']).to eq 'max-age=60, private'

          expect(body_as_json[:orderedItems])
            .to be_an(Array)
            .and be_empty
        end
      end
    end
  end

  private

  def ap_public_collection
    ActivityPub::TagManager::COLLECTIONS[:public]
  end

  def targets_public_collection?(item)
    item[:to].include?(ap_public_collection) || item[:cc].include?(ap_public_collection)
  end

  def targets_followers_collection?(item, account)
    item[:to].include?(
      account_followers_url(account, ActionMailer::Base.default_url_options)
    )
  end
end

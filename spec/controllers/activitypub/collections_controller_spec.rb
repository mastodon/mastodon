# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::CollectionsController, type: :controller do
  let!(:account) { Fabricate(:account) }
  let(:remote_account) { nil }

  shared_examples 'cachable response' do
    it 'does not set cookies' do
      expect(response.cookies).to be_empty
      expect(response.headers['Set-Cookies']).to be nil
    end

    it 'does not set sessions' do
      response
      expect(session).to be_empty
    end

    it 'returns public Cache-Control header' do
      expect(response.headers['Cache-Control']).to include 'public'
    end
  end

  before do
    allow(controller).to receive(:signed_request_account).and_return(remote_account)

    Fabricate(:status_pin, account: account)
    Fabricate(:status_pin, account: account)
    Fabricate(:status, account: account, visibility: :private)
  end

  describe 'GET #show' do
    context 'when id is "featured"' do
      context 'without signature' do
        let(:remote_account) { nil }

        subject(:response) { get :show, params: { id: 'featured', account_username: account.username } }
        subject(:body) { body_as_json }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.media_type).to eq 'application/activity+json'
        end

        it_behaves_like 'cachable response'

        it 'returns orderedItems with pinned statuses' do
          expect(body[:orderedItems]).to be_an Array
          expect(body[:orderedItems].size).to eq 2
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

      context 'with signature' do
        let(:remote_account) { Fabricate(:account, domain: 'example.com') }

        context do
          before do
            get :show, params: { id: 'featured', account_username: account.username }
          end

          it 'returns http success' do
            expect(response).to have_http_status(200)
          end

          it 'returns application/activity+json' do
            expect(response.media_type).to eq 'application/activity+json'
          end

          it_behaves_like 'cachable response'

          it 'returns orderedItems with pinned statuses' do
            json = body_as_json
            expect(json[:orderedItems]).to be_an Array
            expect(json[:orderedItems].size).to eq 2
          end
        end

        context 'in authorized fetch mode' do
          before do
            allow(controller).to receive(:authorized_fetch_mode?).and_return(true)
          end

          context 'when signed request account is blocked' do
            before do
              account.block!(remote_account)
              get :show, params: { id: 'featured', account_username: account.username }
            end

            it 'returns http success' do
              expect(response).to have_http_status(200)
            end

            it 'returns application/activity+json' do
              expect(response.media_type).to eq 'application/activity+json'
            end

            it 'returns private Cache-Control header' do
              expect(response.headers['Cache-Control']).to include 'private'
            end

            it 'returns empty orderedItems' do
              json = body_as_json
              expect(json[:orderedItems]).to be_an Array
              expect(json[:orderedItems].size).to eq 0
            end
          end

          context 'when signed request account is domain blocked' do
            before do
              account.block_domain!(remote_account.domain)
              get :show, params: { id: 'featured', account_username: account.username }
            end

            it 'returns http success' do
              expect(response).to have_http_status(200)
            end

            it 'returns application/activity+json' do
              expect(response.media_type).to eq 'application/activity+json'
            end

            it 'returns private Cache-Control header' do
              expect(response.headers['Cache-Control']).to include 'private'
            end

            it 'returns empty orderedItems' do
              json = body_as_json
              expect(json[:orderedItems]).to be_an Array
              expect(json[:orderedItems].size).to eq 0
            end
          end
        end
      end
    end

    context 'when id is not "featured"' do
      it 'returns http not found' do
        get :show, params: { id: 'hoge', account_username: account.username }
        expect(response).to have_http_status(404)
      end
    end
  end
end

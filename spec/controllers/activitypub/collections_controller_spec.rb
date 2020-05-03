# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::CollectionsController, type: :controller do
  let!(:account) { Fabricate(:account) }
  let(:remote_account) { nil }

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

        before do
          get :show, params: { id: 'featured', account_username: account.username }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.content_type).to eq 'application/activity+json'
        end

        it 'returns public Cache-Control header' do
          expect(response.headers['Cache-Control']).to include 'public'
        end

        it 'returns orderedItems with pinned statuses' do
          json = body_as_json
          expect(json[:orderedItems]).to be_an Array
          expect(json[:orderedItems].size).to eq 2
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
            expect(response.content_type).to eq 'application/activity+json'
          end

          it 'returns public Cache-Control header' do
            expect(response.headers['Cache-Control']).to include 'public'
          end

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
              expect(response.content_type).to eq 'application/activity+json'
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
              expect(response.content_type).to eq 'application/activity+json'
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

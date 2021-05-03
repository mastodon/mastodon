# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::RepliesController, type: :controller do
  let(:status) { Fabricate(:status, visibility: parent_visibility) }
  let(:remote_account) { nil }

  before do
    allow(controller).to receive(:signed_request_account).and_return(remote_account)

    Fabricate(:status, thread: status, visibility: :public)
    Fabricate(:status, thread: status, visibility: :public)
    Fabricate(:status, thread: status, visibility: :private)
    Fabricate(:status, account: status.account, thread: status, visibility: :public)
    Fabricate(:status, account: status.account, thread: status, visibility: :private)
  end

  describe 'GET #index' do
    context 'with no signature' do
      before do
        get :index, params: { account_username: status.account.username, status_id: status.id }
      end

      context 'when status is public' do
        let(:parent_visibility) { :public }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.content_type).to eq 'application/activity+json'
        end

        it 'returns public Cache-Control header' do
          expect(response.headers['Cache-Control']).to include 'public'
        end

        it 'returns items with account\'s own replies' do
          json = body_as_json

          expect(json[:first]).to be_a Hash
          expect(json[:first][:items]).to be_an Array
          expect(json[:first][:items].size).to eq 1
          expect(json[:first][:items].all? { |item| item[:to].include?(ActivityPub::TagManager::COLLECTIONS[:public]) || item[:cc].include?(ActivityPub::TagManager::COLLECTIONS[:public]) }).to be true
        end
      end

      context 'when status is private' do
        let(:parent_visibility) { :private }

        it 'returns http not found' do
          expect(response).to have_http_status(404)
        end
      end

      context 'when status is direct' do
        let(:parent_visibility) { :direct }

        it 'returns http not found' do
          expect(response).to have_http_status(404)
        end
      end
    end

    context 'with signature' do
      let(:remote_account) { Fabricate(:account, domain: 'example.com') }
      let(:only_other_accounts) { nil }

      context do
        before do
          get :index, params: { account_username: status.account.username, status_id: status.id, only_other_accounts: only_other_accounts }
        end

        context 'when status is public' do
          let(:parent_visibility) { :public }

          it 'returns http success' do
            expect(response).to have_http_status(200)
          end

          it 'returns application/activity+json' do
            expect(response.content_type).to eq 'application/activity+json'
          end

          it 'returns public Cache-Control header' do
            expect(response.headers['Cache-Control']).to include 'public'
          end

          context 'without only_other_accounts' do
            it 'returns items with account\'s own replies' do
              json = body_as_json

              expect(json[:first]).to be_a Hash
              expect(json[:first][:items]).to be_an Array
              expect(json[:first][:items].size).to eq 1
              expect(json[:first][:items].all? { |item| item[:to].include?(ActivityPub::TagManager::COLLECTIONS[:public]) || item[:cc].include?(ActivityPub::TagManager::COLLECTIONS[:public]) }).to be true
            end
          end

          context 'with only_other_accounts' do
            let(:only_other_accounts) { 'true' }

            it 'returns items with other public or unlisted replies' do
              json = body_as_json

              expect(json[:first]).to be_a Hash
              expect(json[:first][:items]).to be_an Array
              expect(json[:first][:items].size).to eq 2
              expect(json[:first][:items].all? { |item| item[:to].include?(ActivityPub::TagManager::COLLECTIONS[:public]) || item[:cc].include?(ActivityPub::TagManager::COLLECTIONS[:public]) }).to be true
            end
          end
        end

        context 'when status is private' do
          let(:parent_visibility) { :private }

          it 'returns http not found' do
            expect(response).to have_http_status(404)
          end
        end

        context 'when status is direct' do
          let(:parent_visibility) { :direct }

          it 'returns http not found' do
            expect(response).to have_http_status(404)
          end
        end
      end

      context 'when signed request account is blocked' do
        before do
          status.account.block!(remote_account)
          get :index, params: { account_username: status.account.username, status_id: status.id }
        end

        context 'when status is public' do
          let(:parent_visibility) { :public }

          it 'returns http not found' do
            expect(response).to have_http_status(404)
          end
        end

        context 'when status is private' do
          let(:parent_visibility) { :private }

          it 'returns http not found' do
            expect(response).to have_http_status(404)
          end
        end

        context 'when status is direct' do
          let(:parent_visibility) { :direct }

          it 'returns http not found' do
            expect(response).to have_http_status(404)
          end
        end
      end

      context 'when signed request account is domain blocked' do
        before do
          status.account.block_domain!(remote_account.domain)
          get :index, params: { account_username: status.account.username, status_id: status.id }
        end

        context 'when status is public' do
          let(:parent_visibility) { :public }

          it 'returns http not found' do
            expect(response).to have_http_status(404)
          end
        end

        context 'when status is private' do
          let(:parent_visibility) { :private }

          it 'returns http not found' do
            expect(response).to have_http_status(404)
          end
        end

        context 'when status is direct' do
          let(:parent_visibility) { :direct }

          it 'returns http not found' do
            expect(response).to have_http_status(404)
          end
        end
      end
    end
  end
end

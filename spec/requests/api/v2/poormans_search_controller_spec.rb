# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'poormans search' do # ::FilePath
  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:search') }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  before do
    allow(Chewy).to receive(:enabled?).and_return(false)
  end

  describe 'status search' do
    describe 'GET #index' do
      context 'when query is empty' do
        it 'returns http 400' do
          get '/api/v2/search', headers: headers, params: { q: '' }

          expect(response).to have_http_status(400)
        end
      end

      context 'when there are some statuses' do
        let!(:status_relevant) { Fabricate(:status, text: 'test') }

        before do
          Fabricate(:status, text: 'text')
        end

        it 'returns status' do
          get '/api/v2/search', headers: headers, params: { q: 'test' }

          expect(response.parsed_body[:statuses].pluck(:id)).to eq [status_relevant.id.to_s]
        end
      end

      context 'when there are some statuses with complex text and query' do
        let!(:status_relevant) { Fabricate(:status, text: 'test あああ') }

        before do
          Fabricate(:status, text: 'test')
          Fabricate(:status, text: 'あああ')
        end

        it 'returns status' do
          get '/api/v2/search', headers: headers, params: { q: 'test　あああ' }

          expect(response.parsed_body[:statuses].pluck(:id)).to eq [status_relevant.id.to_s]
        end
      end

      context 'when there are some statuses with different users' do
        let!(:alice) { Fabricate(:account, username: 'alice') }
        let!(:bob) { Fabricate(:account, username: 'bob', domain: 'example.com') }
        let!(:alice_status) { Fabricate(:status, text: 'test', account: alice) }
        let!(:bob_status) { Fabricate(:status, text: 'test', account: bob) }

        it 'returns status for alice' do
          get '/api/v2/search', headers: headers, params: { q: 'es from:alice' }

          expect(response.parsed_body[:statuses].pluck(:id)).to eq [alice_status.id.to_s]
        end

        it 'returns status for @alice' do
          get '/api/v2/search', headers: headers, params: { q: 'es from:@alice' }

          expect(response.parsed_body[:statuses].pluck(:id)).to eq [alice_status.id.to_s]
        end

        it 'returns status for bob@example.com' do
          get '/api/v2/search', headers: headers, params: { q: 'es from:bob@example.com' }

          expect(response.parsed_body[:statuses].pluck(:id)).to eq [bob_status.id.to_s]
        end

        it 'returns status for @bob@example.com' do
          get '/api/v2/search', headers: headers, params: { q: 'es from:@bob@example.com' }

          expect(response.parsed_body[:statuses].pluck(:id)).to eq [bob_status.id.to_s]
        end
      end

      context 'when there are private status and public status' do
        before do
          Fabricate(:status, visibility: :public, text: 'word 1')
          Fabricate(:status, visibility: :private, text: 'word 2')
          Fabricate(:status, visibility: :public, text: 'word 3')
          Fabricate(:status, visibility: :public, text: 'word 4')
          Fabricate(:status, visibility: :private, text: 'word 5')
          Fabricate(:status, visibility: :public, text: 'word 6')
        end

        it 'returns word 6, 4, 3 for the first page' do
          get '/api/v2/search', headers: headers, params: { q: 'word', limit: 3 }

          expect(response.parsed_body[:statuses].pluck(:content)).to eq(['word 6', 'word 4', 'word 3'].map { |w| "<p>#{w}</p>" })
        end

        it 'returns word 3, 1 for the second page' do
          get '/api/v2/search', headers: headers, params: { q: 'word', limit: 3, offset: 2, type: :statuses }

          expect(response.parsed_body[:statuses].pluck(:content)).to eq(['word 3', 'word 1'].map { |w| "<p>#{w}</p>" })
        end
      end

      context 'when specified local account' do
        let!(:status_from_local_account) { Fabricate(:status, account: Fabricate(:account, domain: nil), text: 'word 1') }

        before do
          # other status
          Fabricate(:status, text: 'word 2')
        end

        it 'returns status from local user' do
          get '/api/v2/search', headers: headers, params: { q: "word from:@#{status_from_local_account.account.username}", limit: 3 }

          expect(response.parsed_body[:statuses].pluck(:content)).to contain_exactly('<p>word 1</p>')
        end
      end

      context 'when specified me' do
        before do
          # my status
          Fabricate(:status, account: Fabricate(:account, user: user), text: 'word 1')
          # other status
          Fabricate(:status, text: 'word 2')
        end

        it 'returns status from me' do
          get '/api/v2/search', headers: headers, params: { q: 'word from:me', limit: 3 }

          expect(response.parsed_body[:statuses].pluck(:content)).to contain_exactly('<p>word 1</p>')
        end
      end
    end
  end
end

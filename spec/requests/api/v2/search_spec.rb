# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search API' do
  context 'with token' do
    let(:user)    { Fabricate(:user) }
    let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
    let(:scopes)  { 'read:search' }
    let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

    describe 'GET /api/v2/search' do
      let!(:bob)   { Fabricate(:account, username: 'bob_test') }
      let!(:ana)   { Fabricate(:account, username: 'ana_test') }
      let!(:tom)   { Fabricate(:account, username: 'tom_test') }
      let(:params) { { q: 'test' } }

      it 'returns http success' do
        get '/api/v2/search', headers: headers, params: params

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end

      context 'when searching accounts' do
        let(:params) { { q: 'test', type: 'accounts' } }

        it 'returns all matching accounts' do
          get '/api/v2/search', headers: headers, params: params

          expect(response.parsed_body[:accounts].pluck(:id)).to contain_exactly(bob.id.to_s, ana.id.to_s, tom.id.to_s)
        end

        context 'with truthy `resolve`' do
          let(:params) { { q: 'test1', resolve: '1' } }

          it 'returns http unauthorized' do
            get '/api/v2/search', headers: headers, params: params

            expect(response).to have_http_status(200)
            expect(response.content_type)
              .to start_with('application/json')
          end
        end

        context 'with valid `offset` value' do
          let(:params) { { q: 'test1', offset: 1 } }

          it 'returns http unauthorized' do
            get '/api/v2/search', headers: headers, params: params

            expect(response).to have_http_status(200)
            expect(response.content_type)
              .to start_with('application/json')
          end
        end

        context 'with negative `offset` value' do
          let(:params) { { q: 'test1', offset: '-100', type: 'accounts' } }

          it 'returns http bad_request' do
            get '/api/v2/search', headers: headers, params: params

            expect(response).to have_http_status(400)
            expect(response.content_type)
              .to start_with('application/json')
          end
        end

        context 'with negative `limit` value' do
          let(:params) { { q: 'test1', limit: '-100', type: 'accounts' } }

          it 'returns http bad_request' do
            get '/api/v2/search', headers: headers, params: params

            expect(response).to have_http_status(400)
            expect(response.content_type)
              .to start_with('application/json')
          end
        end

        context 'with following=true' do
          let(:params) { { q: 'test', type: 'accounts', following: 'true' } }

          before do
            user.account.follow!(ana)
          end

          it 'returns only the followed accounts' do
            get '/api/v2/search', headers: headers, params: params

            expect(response.parsed_body[:accounts].pluck(:id)).to contain_exactly(ana.id.to_s)
          end
        end
      end

      context 'when search raises syntax error' do
        before { allow(Search).to receive(:new).and_raise(Mastodon::SyntaxError) }

        it 'returns http unprocessable_entity' do
          get '/api/v2/search', headers: headers, params: params

          expect(response).to have_http_status(422)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      context 'when search raises not found error' do
        before { allow(Search).to receive(:new).and_raise(ActiveRecord::RecordNotFound) }

        it 'returns http not_found' do
          get '/api/v2/search', headers: headers, params: params

          expect(response).to have_http_status(404)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end
  end

  context 'without token' do
    describe 'GET /api/v2/search' do
      let(:search_params) { nil }

      before do
        get '/api/v2/search', params: search_params
      end

      context 'without a `q` param' do
        it 'returns http bad_request' do
          expect(response).to have_http_status(400)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      context 'with a `q` shorter than 5 characters' do
        let(:search_params) { { q: 'test' } }

        it 'returns http success' do
          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      context 'with a `q` equal to or longer than 5 characters' do
        let(:search_params) { { q: 'test1' } }

        it 'returns http success' do
          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
        end

        context 'with truthy `resolve`' do
          let(:search_params) { { q: 'test1', resolve: '1' } }

          it 'returns http unauthorized' do
            expect(response).to have_http_status(401)
            expect(response.content_type)
              .to start_with('application/json')
            expect(response.body).to match('resolve remote resources')
          end
        end

        context 'with `offset`' do
          let(:search_params) { { q: 'test1', offset: 1 } }

          it 'returns http unauthorized' do
            expect(response).to have_http_status(401)
            expect(response.content_type)
              .to start_with('application/json')
            expect(response.body).to match('pagination is not supported')
          end
        end
      end
    end
  end
end

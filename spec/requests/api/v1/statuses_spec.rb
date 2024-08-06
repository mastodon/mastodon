# frozen_string_literal: true

require 'rails_helper'

describe '/api/v1/statuses' do
  context 'with an oauth token' do
    let(:user)  { Fabricate(:user) }
    let(:client_app) { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, application: client_app, scopes: scopes) }
    let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

    describe 'GET /api/v1/statuses?id[]=:id' do
      let(:status) { Fabricate(:status) }
      let(:other_status) { Fabricate(:status) }
      let(:scopes) { 'read:statuses' }

      it 'returns expected response' do
        get '/api/v1/statuses', headers: headers, params: { id: [status.id, other_status.id, 123_123] }

        expect(response).to have_http_status(200)
        expect(body_as_json).to contain_exactly(
          hash_including(id: status.id.to_s),
          hash_including(id: other_status.id.to_s)
        )
      end
    end

    describe 'GET /api/v1/statuses/:id' do
      subject do
        get "/api/v1/statuses/#{status.id}", headers: headers
      end

      let(:scopes) { 'read:statuses' }
      let(:status) { Fabricate(:status, account: user.account) }

      it_behaves_like 'forbidden for wrong scope', 'write write:statuses'

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      context 'when post includes filtered terms' do
        let(:status) { Fabricate(:status, text: 'this toot is about that banned word') }

        before do
          user.account.custom_filters.create!(phrase: 'filter1', context: %w(home), action: :hide, keywords_attributes: [{ keyword: 'banned' }, { keyword: 'irrelevant' }])
        end

        it 'returns filter information', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(body_as_json[:filtered][0]).to include({
            filter: a_hash_including({
              id: user.account.custom_filters.first.id.to_s,
              title: 'filter1',
              filter_action: 'hide',
            }),
            keyword_matches: ['banned'],
          })
        end
      end

      context 'when post is explicitly filtered' do
        let(:status) { Fabricate(:status, text: 'hello world') }

        before do
          filter = user.account.custom_filters.create!(phrase: 'filter1', context: %w(home), action: :hide)
          filter.statuses.create!(status_id: status.id)
        end

        it 'returns filter information', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(body_as_json[:filtered][0]).to include({
            filter: a_hash_including({
              id: user.account.custom_filters.first.id.to_s,
              title: 'filter1',
              filter_action: 'hide',
            }),
            status_matches: [status.id.to_s],
          })
        end
      end

      context 'when reblog includes filtered terms' do
        let(:status) { Fabricate(:status, reblog: Fabricate(:status, text: 'this toot is about that banned word')) }

        before do
          user.account.custom_filters.create!(phrase: 'filter1', context: %w(home), action: :hide, keywords_attributes: [{ keyword: 'banned' }, { keyword: 'irrelevant' }])
        end

        it 'returns filter information', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(body_as_json[:reblog][:filtered][0]).to include({
            filter: a_hash_including({
              id: user.account.custom_filters.first.id.to_s,
              title: 'filter1',
              filter_action: 'hide',
            }),
            keyword_matches: ['banned'],
          })
        end
      end
    end

    describe 'GET /api/v1/statuses/:id/context' do
      let(:scopes) { 'read:statuses' }
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        Fabricate(:status, account: user.account, thread: status)
      end

      it 'returns http success' do
        get "/api/v1/statuses/#{status.id}/context", headers: headers

        expect(response).to have_http_status(200)
      end
    end

    describe 'POST /api/v1/statuses' do
      subject do
        post '/api/v1/statuses', headers: headers, params: params
      end

      let(:scopes) { 'write:statuses' }
      let(:params) { { status: 'Hello world' } }

      it_behaves_like 'forbidden for wrong scope', 'read read:statuses'

      context 'with a basic status body' do
        it 'returns rate limit headers', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq (RateLimiter::FAMILIES[:statuses][:limit] - 1).to_s
        end
      end

      context 'with a safeguard' do
        let!(:alice) { Fabricate(:account, username: 'alice') }
        let!(:bob)   { Fabricate(:account, username: 'bob') }

        let(:params) { { status: '@alice hm, @bob is really annoying lately', allowed_mentions: [alice.id] } }

        it 'returns serialized extra accounts in body', :aggregate_failures do
          subject

          expect(response).to have_http_status(422)
          expect(body_as_json[:unexpected_accounts].map { |a| a.slice(:id, :acct) }).to eq [{ id: bob.id.to_s, acct: bob.acct }]
        end
      end

      context 'with missing parameters' do
        let(:params) { {} }

        it 'returns rate limit headers', :aggregate_failures do
          subject

          expect(response).to have_http_status(422)
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
        end
      end

      context 'when exceeding rate limit' do
        before do
          rate_limiter = RateLimiter.new(user.account, family: :statuses)
          RateLimiter::FAMILIES[:statuses][:limit].times { rate_limiter.record! }
        end

        it 'returns rate limit headers', :aggregate_failures do
          subject

          expect(response).to have_http_status(429)
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq '0'
        end
      end

      context 'with missing thread' do
        let(:params) { { status: 'Hello world', in_reply_to_id: 0 } }

        it 'returns http not found' do
          subject

          expect(response).to have_http_status(404)
        end
      end

      context 'when scheduling a status' do
        let(:params) { { status: 'Hello world', scheduled_at: 10.minutes.from_now } }
        let(:account) { user.account }

        it 'returns HTTP 200' do
          subject

          expect(response).to have_http_status(200)
        end

        it 'creates a scheduled status' do
          expect { subject }.to change { account.scheduled_statuses.count }.from(0).to(1)
        end

        context 'when the scheduling time is less than 5 minutes' do
          let(:params) { { status: 'Hello world', scheduled_at: 4.minutes.from_now } }

          it 'does not create a scheduled status', :aggregate_failures do
            subject

            expect(response).to have_http_status(422)
            expect(account.scheduled_statuses).to be_empty
          end
        end
      end
    end

    describe 'DELETE /api/v1/statuses/:id' do
      subject do
        delete "/api/v1/statuses/#{status.id}", headers: headers
      end

      let(:scopes) { 'write:statuses' }
      let(:status) { Fabricate(:status, account: user.account) }

      it_behaves_like 'forbidden for wrong scope', 'read read:statuses'

      it 'removes the status', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(Status.find_by(id: status.id)).to be_nil
      end
    end

    describe 'PUT /api/v1/statuses/:id' do
      subject do
        put "/api/v1/statuses/#{status.id}", headers: headers, params: { status: 'I am updated' }
      end

      let(:scopes) { 'write:statuses' }
      let(:status) { Fabricate(:status, account: user.account) }

      it_behaves_like 'forbidden for wrong scope', 'read read:statuses'

      it 'updates the status', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(status.reload.text).to eq 'I am updated'
      end
    end
  end

  context 'without an oauth token' do
    context 'with a private status' do
      let(:status) { Fabricate(:status, visibility: :private) }

      describe 'GET /api/v1/statuses/:id' do
        it 'returns http unauthorized' do
          get "/api/v1/statuses/#{status.id}"

          expect(response).to have_http_status(404)
        end
      end

      describe 'GET /api/v1/statuses/:id/context' do
        before do
          Fabricate(:status, thread: status)
        end

        it 'returns http unauthorized' do
          get "/api/v1/statuses/#{status.id}/context"

          expect(response).to have_http_status(404)
        end
      end
    end

    context 'with a public status' do
      let(:status) { Fabricate(:status, visibility: :public) }

      describe 'GET /api/v1/statuses/:id' do
        it 'returns http success' do
          get "/api/v1/statuses/#{status.id}"

          expect(response).to have_http_status(200)
        end
      end

      describe 'GET /api/v1/statuses/:id/context' do
        before do
          Fabricate(:status, thread: status)
        end

        it 'returns http success' do
          get "/api/v1/statuses/#{status.id}/context"

          expect(response).to have_http_status(200)
        end
      end
    end
  end
end

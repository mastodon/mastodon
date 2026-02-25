# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/statuses' do
  context 'with an oauth token' do
    include_context 'with API authentication'

    let(:client_app) { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, application: client_app, scopes: scopes) }

    describe 'GET /api/v1/statuses?id[]=:id' do
      let(:status) { Fabricate(:status) }
      let(:other_status) { Fabricate(:status) }
      let(:scopes) { 'read:statuses' }

      it 'returns expected response' do
        get '/api/v1/statuses', headers: headers, params: { id: [status.id, other_status.id, 123_123] }

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to contain_exactly(
          hash_including(id: status.id.to_s),
          hash_including(id: other_status.id.to_s)
        )
      end

      context 'with too many IDs' do
        before { stub_const 'Api::BaseController::DEFAULT_STATUSES_LIMIT', 2 }

        it 'returns error response' do
          get '/api/v1/statuses', headers: headers, params: { id: [123, 456, 789] }

          expect(response)
            .to have_http_status(422)
          expect(response.content_type)
            .to start_with('application/json')
        end
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
        expect(response.content_type)
          .to start_with('application/json')
      end

      context 'when post includes filtered terms' do
        let(:status) { Fabricate(:status, text: 'this toot is about that banned word') }

        before do
          user.account.custom_filters.create!(phrase: 'filter1', context: %w(home), action: :hide, keywords_attributes: [{ keyword: 'banned' }, { keyword: 'irrelevant' }])
        end

        it 'returns filter information', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body[:filtered][0]).to include({
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
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body[:filtered][0]).to include({
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
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body[:reblog][:filtered][0]).to include({
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
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.headers['Mastodon-Async-Refresh']).to be_nil
      end

      context 'with a remote status' do
        let(:status) { Fabricate(:status, account: Fabricate(:account, domain: 'example.com'), created_at: 1.hour.ago, updated_at: 1.hour.ago) }

        it 'returns http success and queues discovery of new posts' do
          expect { get "/api/v1/statuses/#{status.id}/context", headers: headers }
            .to enqueue_sidekiq_job(ActivityPub::FetchAllRepliesWorker)

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.headers['Mastodon-Async-Refresh']).to match(/result_count=0/)
        end
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
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq (RateLimiter::FAMILIES[:statuses][:limit] - 1).to_s
        end
      end

      context 'without a quote policy' do
        let(:user) do
          Fabricate(:user, settings: { default_quote_policy: 'followers' })
        end

        it 'returns post with user default quote policy, as well as rate limit headers', :aggregate_failures do
          subject
          expect(user.setting_default_quote_policy).to eq 'followers'

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body[:quote_approval]).to include({
            automatic: ['followers'],
            manual: [],
            current_user: 'automatic',
          })
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq (RateLimiter::FAMILIES[:statuses][:limit] - 1).to_s
        end
      end

      context 'without a quote policy and the user defaults to nobody' do
        let(:user) do
          Fabricate(:user, settings: { default_quote_policy: 'nobody' })
        end

        it 'returns post with user default quote policy, as well as rate limit headers', :aggregate_failures do
          subject
          expect(user.setting_default_quote_policy).to eq 'nobody'

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body[:quote_approval]).to include({
            automatic: [],
            manual: [],
            current_user: 'automatic',
          })
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq (RateLimiter::FAMILIES[:statuses][:limit] - 1).to_s
        end
      end

      context 'with a quote policy' do
        let(:quoted_status) { Fabricate(:status, account: user.account) }
        let(:params) do
          {
            status: 'Hello world, this is a self-quote',
            quote_approval_policy: 'followers',
          }
        end

        it 'returns post with appropriate quote policy, as well as rate limit headers', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body[:quote_approval]).to include({
            automatic: ['followers'],
            manual: [],
            current_user: 'automatic',
          })
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq (RateLimiter::FAMILIES[:statuses][:limit] - 1).to_s
        end
      end

      context 'with a self-quote post' do
        let!(:quoted_status) { Fabricate(:status, account: user.account) }
        let(:params) do
          {
            status: 'Hello world, this is a self-quote',
            quoted_status_id: quoted_status.id,
          }
        end

        it 'returns a quote post, as well as rate limit headers', :aggregate_failures do
          expect { subject }.to change(user.account.statuses, :count).by(1)

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body[:quote]).to be_present
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq (RateLimiter::FAMILIES[:statuses][:limit] - 1).to_s
        end
      end

      context 'with a quote to a non-mentioned user in a Private Mention' do
        let!(:quoted_status) { Fabricate(:status, quote_approval_policy: InteractionPolicy::POLICY_FLAGS[:public] << 16) }
        let(:params) do
          {
            status: 'Hello, this is a quote',
            quoted_status_id: quoted_status.id,
            visibility: :direct,
          }
        end

        it 'returns an error and does not create a post', :aggregate_failures do
          expect { subject }.to_not change(user.account.statuses, :count)

          expect(response).to have_http_status(422)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      context 'with a quote to a mentioned user in a Private Mention' do
        let!(:quoted_status) { Fabricate(:status, quote_approval_policy: InteractionPolicy::POLICY_FLAGS[:public] << 16) }
        let(:params) do
          {
            status: "Hello @#{quoted_status.account.acct}, this is a quote",
            quoted_status_id: quoted_status.id,
            visibility: :direct,
          }
        end

        it 'returns a quote post, as well as rate limit headers', :aggregate_failures do
          expect { subject }.to change(user.account.statuses, :count).by(1)

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body[:quote]).to be_present
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq (RateLimiter::FAMILIES[:statuses][:limit] - 1).to_s
        end
      end

      context 'with a quote of a reblog' do
        let(:quoted_status) { Fabricate(:status, quote_approval_policy: InteractionPolicy::POLICY_FLAGS[:public] << 16) }
        let(:reblog) { Fabricate(:status, reblog: quoted_status) }
        let(:params) do
          {
            status: 'Hello world, this is a self-quote',
            quoted_status_id: reblog.id,
          }
        end

        it 'returns a quote post, as well as rate limit headers', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body[:quote]).to be_present
          expect(response.parsed_body[:quote][:quoted_status][:id]).to eq quoted_status.id.to_s
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq (RateLimiter::FAMILIES[:statuses][:limit] - 1).to_s
        end
      end

      context 'with a self-quote post and a CW but no text' do
        let(:quoted_status) { Fabricate(:status, account: user.account) }
        let(:params) do
          {
            spoiler_text: 'this is a CW',
            quoted_status_id: quoted_status.id,
          }
        end

        it 'returns a quote post, as well as rate limit headers', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body[:quote]).to be_present
          expect(response.parsed_body[:spoiler_text]).to eq 'this is a CW'
          expect(response.parsed_body[:content]).to match(/RE: /)
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
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body[:unexpected_accounts].map { |a| a.slice(:id, :acct) }).to match [{ id: bob.id.to_s, acct: bob.acct }]
        end
      end

      context 'with missing parameters' do
        let(:params) { {} }

        it 'returns rate limit headers', :aggregate_failures do
          subject

          expect(response).to have_http_status(422)
          expect(response.content_type)
            .to start_with('application/json')
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
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq '0'
        end
      end

      context 'with missing thread' do
        let(:params) { { status: 'Hello world', in_reply_to_id: 0 } }

        it 'returns http not found' do
          subject

          expect(response).to have_http_status(404)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      context 'when scheduling a status' do
        let(:params) { { status: 'Hello world', scheduled_at: 10.minutes.from_now } }
        let(:account) { user.account }

        it 'returns HTTP 200' do
          subject

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
        end

        it 'creates a scheduled status' do
          expect { subject }.to change { account.scheduled_statuses.count }.from(0).to(1)
        end

        context 'when the scheduling time is less than 5 minutes' do
          let(:params) { { status: 'Hello world', scheduled_at: 4.minutes.from_now } }

          it 'does not create a scheduled status', :aggregate_failures do
            subject

            expect(response).to have_http_status(422)
            expect(response.content_type)
              .to start_with('application/json')
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

      it 'discards the status and schedules removal as a redraft', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(Status.find_by(id: status.id)).to be_nil
        expect(RemovalWorker).to have_enqueued_sidekiq_job(status.id, { 'redraft' => true })
      end

      context 'when called with truthy delete_media' do
        subject do
          delete "/api/v1/statuses/#{status.id}?delete_media=true", headers: headers
        end

        it 'discards the status and schedules removal without the redraft flag', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(Status.find_by(id: status.id)).to be_nil
          expect(RemovalWorker).to have_enqueued_sidekiq_job(status.id, { 'redraft' => false })
        end
      end
    end

    describe 'PUT /api/v1/statuses/:id' do
      subject do
        put "/api/v1/statuses/#{status.id}", headers: headers, params: params
      end

      let(:params) { { status: 'I am updated' } }
      let(:scopes) { 'write:statuses' }
      let(:status) { Fabricate(:status, account: user.account) }

      it_behaves_like 'forbidden for wrong scope', 'read read:statuses'

      it 'updates the status', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(status.reload.text).to eq 'I am updated'
      end

      context 'when updating only the quote policy' do
        let(:params) { { status: status.text, quote_approval_policy: 'public' } }

        it 'updates the status', :aggregate_failures do
          expect { subject }
            .to change { status.reload.quote_approval_policy }.to(InteractionPolicy::POLICY_FLAGS[:public] << 16)

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      context 'when status has non-default quote policy and param is omitted' do
        let(:status) { Fabricate(:status, account: user.account, quote_approval_policy: 'nobody') }

        it 'preserves existing quote approval policy' do
          expect { subject }
            .to_not(change { status.reload.quote_approval_policy })
        end
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
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      describe 'GET /api/v1/statuses/:id/context' do
        before do
          Fabricate(:status, thread: status)
        end

        it 'returns http unauthorized' do
          get "/api/v1/statuses/#{status.id}/context"

          expect(response).to have_http_status(404)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end

    context 'with a public status' do
      let(:status) { Fabricate(:status, visibility: :public) }

      describe 'GET /api/v1/statuses/:id' do
        it 'returns http success' do
          get "/api/v1/statuses/#{status.id}"

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      describe 'GET /api/v1/statuses/:id/context' do
        before do
          Fabricate(:status, thread: status)
        end

        it 'returns http success' do
          get "/api/v1/statuses/#{status.id}/context"

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end
  end
end

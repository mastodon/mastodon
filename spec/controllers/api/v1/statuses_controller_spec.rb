# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::StatusesController do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:app)   { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, application: app, scopes: scopes) }

  context 'with an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { token }
    end

    describe 'GET #show' do
      let(:scopes) { 'read:statuses' }
      let(:status) { Fabricate(:status, account: user.account) }

      it 'returns http success' do
        get :show, params: { id: status.id }
        expect(response).to have_http_status(200)
      end

      context 'when post includes filtered terms' do
        let(:status) { Fabricate(:status, text: 'this toot is about that banned word') }

        before do
          user.account.custom_filters.create!(phrase: 'filter1', context: %w(home), action: :hide, keywords_attributes: [{ keyword: 'banned' }, { keyword: 'irrelevant' }])
        end

        it 'returns filter information', :aggregate_failures do
          get :show, params: { id: status.id }
          json = body_as_json

          expect(response).to have_http_status(200)
          expect(json[:filtered][0]).to include({
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
          get :show, params: { id: status.id }
          json = body_as_json

          expect(response).to have_http_status(200)
          expect(json[:filtered][0]).to include({
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
          get :show, params: { id: status.id }
          json = body_as_json

          expect(response).to have_http_status(200)
          expect(json[:reblog][:filtered][0]).to include({
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

    describe 'GET #context' do
      let(:scopes) { 'read:statuses' }
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        Fabricate(:status, account: user.account, thread: status)
      end

      it 'returns http success' do
        get :context, params: { id: status.id }
        expect(response).to have_http_status(200)
      end
    end

    describe 'POST #create' do
      let(:scopes) { 'write:statuses' }

      context 'with a basic status body' do
        before do
          post :create, params: { status: 'Hello world' }
        end

        it 'returns rate limit headers', :aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq (RateLimiter::FAMILIES[:statuses][:limit] - 1).to_s
        end
      end

      context 'with a safeguard' do
        let!(:alice) { Fabricate(:account, username: 'alice') }
        let!(:bob)   { Fabricate(:account, username: 'bob') }

        before do
          post :create, params: { status: '@alice hm, @bob is really annoying lately', allowed_mentions: [alice.id] }
        end

        it 'returns serialized extra accounts in body', :aggregate_failures do
          expect(response).to have_http_status(422)
          expect(body_as_json[:unexpected_accounts].map { |a| a.slice(:id, :acct) }).to eq [{ id: bob.id.to_s, acct: bob.acct }]
        end
      end

      context 'with missing parameters' do
        before do
          post :create, params: {}
        end

        it 'returns rate limit headers', :aggregate_failures do
          expect(response).to have_http_status(422)
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
        end
      end

      context 'when exceeding rate limit' do
        before do
          rate_limiter = RateLimiter.new(user.account, family: :statuses)
          300.times { rate_limiter.record! }
          post :create, params: { status: 'Hello world' }
        end

        it 'returns rate limit headers', :aggregate_failures do
          expect(response).to have_http_status(429)
          expect(response.headers['X-RateLimit-Limit']).to eq RateLimiter::FAMILIES[:statuses][:limit].to_s
          expect(response.headers['X-RateLimit-Remaining']).to eq '0'
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:scopes) { 'write:statuses' }
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        post :destroy, params: { id: status.id }
      end

      it 'removes the status', :aggregate_failures do
        expect(response).to have_http_status(200)
        expect(Status.find_by(id: status.id)).to be_nil
      end
    end

    describe 'PUT #update' do
      let(:scopes) { 'write:statuses' }
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        put :update, params: { id: status.id, status: 'I am updated' }
      end

      it 'updates the status', :aggregate_failures do
        expect(response).to have_http_status(200)
        expect(status.reload.text).to eq 'I am updated'
      end
    end
  end

  context 'without an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token).and_return(nil)
    end

    context 'with a private status' do
      let(:status) { Fabricate(:status, account: user.account, visibility: :private) }

      describe 'GET #show' do
        it 'returns http unauthorized' do
          get :show, params: { id: status.id }
          expect(response).to have_http_status(404)
        end
      end

      describe 'GET #context' do
        before do
          Fabricate(:status, account: user.account, thread: status)
        end

        it 'returns http unauthorized' do
          get :context, params: { id: status.id }
          expect(response).to have_http_status(404)
        end
      end
    end

    context 'with a public status' do
      let(:status) { Fabricate(:status, account: user.account, visibility: :public) }

      describe 'GET #show' do
        it 'returns http success' do
          get :show, params: { id: status.id }
          expect(response).to have_http_status(200)
        end
      end

      describe 'GET #context' do
        before do
          Fabricate(:status, account: user.account, thread: status)
        end

        it 'returns http success' do
          get :context, params: { id: status.id }
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end

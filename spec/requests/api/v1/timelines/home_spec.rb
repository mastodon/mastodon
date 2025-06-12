# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Home', :inline_jobs do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read:statuses' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/timelines/home' do
    subject do
      get '/api/v1/timelines/home', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'write write:statuses'

    context 'when the timeline is available' do
      let(:home_statuses) { bob.statuses + ana.statuses }
      let!(:bob)          { Fabricate(:account) }
      let!(:tim)          { Fabricate(:account) }
      let!(:ana)          { Fabricate(:account) }

      before do
        user.account.follow!(bob)
        user.account.follow!(ana)
        quoted = PostStatusService.new.call(bob, text: 'New toot from bob.')
        PostStatusService.new.call(tim, text: 'New toot from tim.')
        reblogged = PostStatusService.new.call(tim, text: 'New toot from tim, which will end up boosted.')
        ReblogService.new.call(bob, reblogged)
        # TODO: use PostStatusService argument when available rather than manually creating quote
        quoting = PostStatusService.new.call(bob, text: 'Self-quote from bob.')
        Quote.create!(status: quoting, quoted_status: quoted, state: :accepted)
        PostStatusService.new.call(ana, text: 'New toot from ana.')
      end

      it 'returns http success and statuses of followed users' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body.pluck(:id)).to match_array(home_statuses.map { |status| status.id.to_s })
      end

      context 'with limit param' do
        let(:params) { { limit: 1 } }

        it 'returns only the requested number of statuses with pagination headers', :aggregate_failures do
          subject

          expect(response.parsed_body.size).to eq(params[:limit])

          expect(response)
            .to include_pagination_headers(
              prev: api_v1_timelines_home_url(limit: params[:limit], min_id: ana.statuses.first.id),
              next: api_v1_timelines_home_url(limit: params[:limit], max_id: ana.statuses.first.id)
            )
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end

    context 'when the timeline is regenerating' do
      let(:async_refresh) { AsyncRefresh.create("account:#{user.account_id}:regeneration") }
      let(:timeline) { instance_double(HomeFeed, regenerating?: true, get: [], async_refresh:) }

      before do
        allow(HomeFeed).to receive(:new).and_return(timeline)
      end

      it 'returns http partial content' do
        subject

        expect(response).to have_http_status(206)
        expect(response.headers['Mastodon-Async-Refresh']).to eq "id=\"#{async_refresh.id}\", retry=5"
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'without an authorization header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'without a user context' do
      let(:token) { Fabricate(:accessible_access_token, resource_owner_id: nil, scopes: scopes) }

      it 'returns http unprocessable entity', :aggregate_failures do
        subject

        expect(response)
          .to have_http_status(422)
          .and not_have_http_link_header
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end

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
        PostStatusService.new.call(bob, text: 'New toot from bob.')
        PostStatusService.new.call(tim, text: 'New toot from tim.')
        PostStatusService.new.call(ana, text: 'New toot from ana.')
      end

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'returns the statuses of followed users' do
        subject

        expect(response.parsed_body.pluck(:id)).to match_array(home_statuses.map { |status| status.id.to_s })
      end

      context 'with limit param' do
        let(:params) { { limit: 1 } }

        it 'returns only the requested number of statuses' do
          subject

          expect(response.parsed_body.size).to eq(params[:limit])
        end

        it 'sets the correct pagination headers', :aggregate_failures do
          subject

          expect(response)
            .to include_pagination_headers(
              prev: api_v1_timelines_home_url(limit: params[:limit], min_id: ana.statuses.first.id),
              next: api_v1_timelines_home_url(limit: params[:limit], max_id: ana.statuses.first.id)
            )
        end
      end
    end

    context 'when the timeline is regenerating' do
      let(:timeline) { instance_double(HomeFeed, regenerating?: true, get: []) }

      before do
        allow(HomeFeed).to receive(:new).and_return(timeline)
      end

      it 'returns http partial content' do
        subject

        expect(response).to have_http_status(206)
      end
    end

    context 'without an authorization header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
      end
    end

    context 'without a user context' do
      let(:token) { Fabricate(:accessible_access_token, resource_owner_id: nil, scopes: scopes) }

      it 'returns http unprocessable entity', :aggregate_failures do
        subject

        expect(response)
          .to have_http_status(422)
          .and not_have_http_link_header
      end
    end
  end
end

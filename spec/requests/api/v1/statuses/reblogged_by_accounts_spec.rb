# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Statuses Reblogged by Accounts' do
  let(:user) { Fabricate(:user) }
  let(:scopes)  { 'read:accounts' }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:alice) { Fabricate(:account) }
  let(:bob)   { Fabricate(:account) }

  context 'with an oauth token' do
    subject do
      get "/api/v1/statuses/#{status.id}/reblogged_by", headers: headers, params: { limit: 2 }
    end

    describe 'GET /api/v1/statuses/:status_id/reblogged_by' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        Fabricate(:status, account: alice, reblog_of_id: status.id)
        Fabricate(:status, account: bob, reblog_of_id: status.id)
      end

      it 'returns accounts who reblogged the status', :aggregate_failures do
        subject

        expect(response)
          .to have_http_status(200)
          .and include_pagination_headers(
            prev: api_v1_status_reblogged_by_index_url(limit: 2, since_id: bob.statuses.first.id),
            next: api_v1_status_reblogged_by_index_url(limit: 2, max_id: alice.statuses.first.id)
          )

        expect(response.parsed_body.size)
          .to eq(2)
        expect(response.parsed_body)
          .to contain_exactly(
            include(id: alice.id.to_s),
            include(id: bob.id.to_s)
          )
      end

      it 'does not return blocked users' do
        user.account.block!(bob)

        subject

        expect(response.parsed_body.size)
          .to eq 1
        expect(response.parsed_body.first[:id]).to eq(alice.id.to_s)
      end
    end
  end

  context 'without an oauth token' do
    subject do
      get "/api/v1/statuses/#{status.id}/reblogged_by", params: { limit: 2 }
    end

    context 'with a private status' do
      let(:status) { Fabricate(:status, account: user.account, visibility: :private) }

      describe 'GET #index' do
        before do
          Fabricate(:status, reblog_of_id: status.id)
        end

        it 'returns http unauthorized' do
          subject

          expect(response).to have_http_status(404)
        end
      end
    end

    context 'with a public status' do
      let(:status) { Fabricate(:status, account: user.account, visibility: :public) }

      describe 'GET #index' do
        before do
          Fabricate(:status, reblog_of_id: status.id)
        end

        it 'returns http success' do
          subject

          expect(response).to have_http_status(200)
        end
      end
    end
  end
end

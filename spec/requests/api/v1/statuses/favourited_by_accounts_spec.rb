# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Statuses Favourited by Accounts' do
  let(:user) { Fabricate(:user) }
  let(:scopes)  { 'read:accounts' }
  # let(:app)   { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:alice) { Fabricate(:account) }
  let(:bob)   { Fabricate(:account) }

  context 'with an oauth token' do
    subject do
      get "/api/v1/statuses/#{status.id}/favourited_by", headers: headers, params: { limit: 2 }
    end

    describe 'GET /api/v1/statuses/:status_id/favourited_by' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        Favourite.create!(account: alice, status: status)
        Favourite.create!(account: bob, status: status)
      end

      it 'returns http success and accounts who favourited the status' do
        subject

        expect(response)
          .to have_http_status(200)
          .and include_pagination_headers(
            prev: api_v1_status_favourited_by_index_url(limit: 2, since_id: Favourite.last.id),
            next: api_v1_status_favourited_by_index_url(limit: 2, max_id: Favourite.first.id)
          )
        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to contain_exactly(
            include(id: alice.id.to_s),
            include(id: bob.id.to_s)
          )
      end

      it 'does not return blocked users' do
        user.account.block!(bob)

        subject

        expect(response.parsed_body)
          .to contain_exactly(
            hash_including(id: alice.id.to_s)
          )
      end
    end
  end

  context 'without an oauth token' do
    subject do
      get "/api/v1/statuses/#{status.id}/favourited_by", params: { limit: 2 }
    end

    context 'with a private status' do
      let(:status) { Fabricate(:status, account: user.account, visibility: :private) }

      describe 'GET #index' do
        before do
          Fabricate(:favourite, status: status)
        end

        it 'returns http unauthorized' do
          subject

          expect(response).to have_http_status(404)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end

    context 'with a public status' do
      let(:status) { Fabricate(:status, account: user.account, visibility: :public) }

      describe 'GET #index' do
        before do
          Fabricate(:favourite, status: status)
        end

        it 'returns http success' do
          subject

          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end
  end
end

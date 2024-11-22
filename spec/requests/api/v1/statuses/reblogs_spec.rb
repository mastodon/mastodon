# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Statuses Reblogs' do
  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'write:statuses' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  context 'with an oauth token' do
    describe 'POST /api/v1/statuses/:status_id/reblog' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        post "/api/v1/statuses/#{status.id}/reblog", headers: headers
      end

      context 'with public status' do
        it 'reblogs the status', :aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')

          expect(status.reblogs.count).to eq 1

          expect(user.account.reblogged?(status)).to be true

          expect(response.parsed_body)
            .to include(
              reblog: include(
                id: status.id.to_s,
                reblogs_count: 1,
                reblogged: true
              )
            )
        end
      end

      context 'with private status of not-followed account' do
        let(:status) { Fabricate(:status, visibility: :private) }

        it 'returns http not found' do
          expect(response).to have_http_status(404)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end

    describe 'POST /api/v1/statuses/:status_id/unreblog', :inline_jobs do
      context 'with public status' do
        let(:status) { Fabricate(:status, account: user.account) }

        before do
          ReblogService.new.call(user.account, status)
          post "/api/v1/statuses/#{status.id}/unreblog", headers: headers
        end

        it 'destroys the reblog', :aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')

          expect(status.reblogs.count).to eq 0

          expect(user.account.reblogged?(status)).to be false

          expect(response.parsed_body)
            .to include(
              id: status.id.to_s,
              reblogs_count: 0,
              reblogged: false
            )
        end
      end

      context 'with public status when blocked by its author' do
        let(:status) { Fabricate(:status, account: user.account) }

        before do
          ReblogService.new.call(user.account, status)
          status.account.block!(user.account)
          post "/api/v1/statuses/#{status.id}/unreblog", headers: headers
        end

        it 'destroys the reblog', :aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')

          expect(status.reblogs.count).to eq 0

          expect(user.account.reblogged?(status)).to be false

          expect(response.parsed_body)
            .to include(
              id: status.id.to_s,
              reblogs_count: 0,
              reblogged: false
            )
        end
      end

      context 'with private status that was not reblogged' do
        let(:status) { Fabricate(:status, visibility: :private) }

        before do
          post "/api/v1/statuses/#{status.id}/unreblog", headers: headers
        end

        it 'returns http not found' do
          expect(response).to have_http_status(404)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end
  end
end

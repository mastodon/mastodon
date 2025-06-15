# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AsyncRefreshes' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:job) { AsyncRefresh.new('test_job') }

  describe 'GET /api/v1_alpha/async_refreshes/:id' do
    context 'when not authorized' do
      it 'returns http unauthorized' do
        get api_v1_alpha_async_refresh_path(job.id)

        expect(response)
          .to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with wrong scope' do
      before do
        get api_v1_alpha_async_refresh_path(job.id), headers: headers
      end

      it_behaves_like 'forbidden for wrong scope', 'write write:accounts'
    end

    context 'with correct scope' do
      let(:scopes) { 'read' }

      context 'when job exists' do
        before do
          redis.hset('test_job', { 'status' => 'running', 'result_count' => 10 })
        end

        after do
          redis.del('test_job')
        end

        it 'returns http success' do
          get api_v1_alpha_async_refresh_path(job.id), headers: headers

          expect(response)
            .to have_http_status(200)

          expect(response.content_type)
            .to start_with('application/json')

          parsed_response = response.parsed_body
          expect(parsed_response)
            .to be_present
          expect(parsed_response['async_refresh'])
            .to include('status' => 'running', 'result_count' => 10)
        end
      end

      context 'when job does not exist' do
        it 'returns not found' do
          get api_v1_alpha_async_refresh_path(job.id), headers: headers

          expect(response)
            .to have_http_status(404)
        end
      end
    end
  end
end

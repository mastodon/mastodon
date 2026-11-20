# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Requests with an invalid access token' do
  let(:account) { Fabricate(:account) }

  before { Fabricate(:status, account: account) }

  shared_examples 'a request served to anonymous visitors' do
    it 'serves the request without a token' do
      get path

      expect(response).to have_http_status(200)
    end

    it 'rejects an access token that does not exist', :aggregate_failures do
      get path, headers: { 'Authorization' => 'Bearer not-a-real-token' }

      expect(response).to have_http_status(401)
      expect(response.headers['WWW-Authenticate']).to include('invalid_token')
      expect(response.parsed_body[:error]).to be_present
    end

    it 'rejects an access token passed as a parameter that does not exist' do
      get path, params: { access_token: 'not-a-real-token' }

      expect(response).to have_http_status(401)
    end

    it 'rejects a revoked access token' do
      token = Fabricate(:accessible_access_token, scopes: 'read')
      token.revoke

      get path, headers: { 'Authorization' => "Bearer #{token.token}" }

      expect(response).to have_http_status(401)
    end

    it 'serves the request with a valid access token' do
      token = Fabricate(:accessible_access_token, scopes: 'read')

      get path, headers: { 'Authorization' => "Bearer #{token.token}" }

      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /api/v1/accounts/:id/statuses' do
    let(:path) { "/api/v1/accounts/#{account.id}/statuses" }

    it_behaves_like 'a request served to anonymous visitors'
  end

  describe 'GET /api/v1/timelines/public' do
    let(:path) { '/api/v1/timelines/public' }

    it_behaves_like 'a request served to anonymous visitors'
  end

  describe 'GET /api/v1/statuses/:id' do
    let(:path) { "/api/v1/statuses/#{account.statuses.first.id}" }

    it_behaves_like 'a request served to anonymous visitors'
  end
end

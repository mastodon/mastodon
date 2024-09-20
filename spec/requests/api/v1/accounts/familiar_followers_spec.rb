# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts Familiar Followers API' do
  let(:user)     { Fabricate(:user) }
  let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)   { 'read:follows' }
  let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }
  let(:account) { Fabricate(:account) }

  describe 'GET /api/v1/accounts/familiar_followers' do
    it 'returns http success' do
      get '/api/v1/accounts/familiar_followers', params: { account_id: account.id, limit: 2 }, headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end

    context 'when there are duplicate account IDs in the params' do
      let(:account_a) { Fabricate(:account) }
      let(:account_b) { Fabricate(:account) }

      it 'removes duplicate account IDs from params' do
        account_ids = [account_a, account_b, account_b, account_a, account_a].map { |a| a.id.to_s }
        get '/api/v1/accounts/familiar_followers', params: { id: account_ids }, headers: headers

        expect(response.parsed_body.pluck(:id)).to contain_exactly(account_a.id.to_s, account_b.id.to_s)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts Lists API' do
  let(:user)     { Fabricate(:user) }
  let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)   { 'read:lists' }
  let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }
  let(:account) { Fabricate(:account) }
  let(:list)    { Fabricate(:list, account: user.account) }

  before do
    user.account.follow!(account)
    list.accounts << account
  end

  describe 'GET /api/v1/accounts/lists' do
    it 'returns http success' do
      get "/api/v1/accounts/#{account.id}/lists", headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end
end

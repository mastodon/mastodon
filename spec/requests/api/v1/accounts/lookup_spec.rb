# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts Lookup API' do
  include_context 'with API authentication', oauth_scopes: 'read:accounts'

  let(:account) { Fabricate(:account) }

  describe 'GET /api/v1/accounts/lookup' do
    it 'returns http success' do
      get '/api/v1/accounts/lookup', params: { account_id: account.id, acct: account.acct }, headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end
end

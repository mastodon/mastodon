# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts Search API' do
  include_context 'with API authentication', oauth_scopes: 'read:accounts'

  describe 'GET /api/v1/accounts/search' do
    it 'returns http success' do
      get '/api/v1/accounts/search', params: { q: 'query' }, headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end
end

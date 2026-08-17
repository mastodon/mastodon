# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts Lists API' do
  include_context 'with API authentication', oauth_scopes: 'read:lists'

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

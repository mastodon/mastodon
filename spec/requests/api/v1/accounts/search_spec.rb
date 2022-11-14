# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::SearchController, type: :request do
  path '/api/v1/accounts/search' do
    get('show search') do
      tags 'Api', 'V1', 'Accounts', 'Search'
      operationId 'v1AccountsSearchShowSearch'
      rswag_auth_scope %w(read read:accounts)
      parameter name: 'q', in: :query, type: :string, required: true,
                description: 'What to search for'
      parameter name: 'limit', in: :query, type: :integer, required: false,
                description: 'Maximum number of results. Defaults to 40.'
      parameter name: 'resolve', in: :query, type: :string, required: false,
                description: 'Attempt WebFinger lookup. Defaults to false. Use this when q is an exact address.'
      parameter name: 'following', in: :query, type: :boolean, required: false,
                description: 'Only who the user is following. Defaults to false.'

      include_context 'user token auth'

      let!(:account1) { Fabricate(:account, username: 'account1', display_name: 'account no1') }
      let!(:account2) { Fabricate(:account, username: 'account2', display_name: 'account no2') }
      let!(:account3) { Fabricate(:account, username: 'account3', display_name: 'account no3') }
      let!(:account4) { Fabricate(:account, username: 'account4', display_name: 'account no4') }
      let(:q) { 'account3' }

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Account' }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to match_array(
            [
              include(
                { id: account3.id.to_s, username: 'account3' }.stringify_keys
              ),
            ]
          )
        end
      end
    end
  end
end

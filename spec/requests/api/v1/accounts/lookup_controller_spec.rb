# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::LookupController do
  path '/api/v1/accounts/lookup' do
    get('show lookup') do
      tags 'Api', 'V1', 'Accounts', 'Lookup'
      description 'Allows converting a username@domain into a local ID quickly (unlike search, it does not resolve anything, and as such, is available without an API token)'
      operationId 'v1AccountsLookupShowLookup'
      rswag_auth_scope %w(read read:accounts)
      parameter name: 'acct', in: :query, type: :string, required: true

      let!(:account) { Fabricate(:account, username: 'tester', domain: 'nothere.com') }

      include_context 'user token auth'

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Account'
        let(:acct) { account.acct }
        rswag_add_examples!

        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            account.slice(:username, :acct).merge(id: account.id.to_s).stringify_keys
          )
        end
      end
    end
  end
end

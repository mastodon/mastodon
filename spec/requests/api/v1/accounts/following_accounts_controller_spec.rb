# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::FollowingAccountsController do
  path '/api/v1/accounts/{account_id}/following' do
    # You'll want to customize the parameter types...
    parameter name: 'account_id', in: :path, type: :string, description: 'account_id'

    get('list following_accounts') do
      tags 'Api', 'V1', 'Accounts', 'FollowingAccounts'
      operationId 'v1AccountsFollowingaccountsListFollowingAccount'
      rswag_auth_scope(%w(read read:accounts))
      parameter name: 'limit', in: :query, type: :integer, required: false,
                description: 'Maximum number of results to return. Defaults to 40.'
      parameter name: 'max_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'
      parameter name: 'since_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'

      let(:account) { Fabricate(:account) }
      let(:alice)   { Fabricate(:account) }
      let(:bob)     { Fabricate(:account) }
      let(:jane) { Fabricate(:account) }

      include_context 'user token auth'

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Account' }
        let(:account_id) { account.id.to_s }

        before do
          account.follow!(alice)
          account.follow!(bob)
          jane.follow!(account)
        end

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to match_array([
                                        include(alice.slice('username').merge(id: alice.id.to_s).stringify_keys),
                                        include(bob.slice('username').merge(id: bob.id.to_s).stringify_keys),
                                      ])
        end
      end
    end
  end
end

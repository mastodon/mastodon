# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::FollowingAccountsController, type: :request do
  path '/api/v1/accounts/{account_id}/following' do
    # You'll want to customize the parameter types...
    parameter name: 'account_id', in: :path, type: :string, description: 'account_id'

    get('list following_accounts') do
      tags 'Api', 'V1', 'Accounts', 'FollowingAccounts'
      operationId 'v1AccountsFollowingaccountsListFollowingAccount'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:account_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

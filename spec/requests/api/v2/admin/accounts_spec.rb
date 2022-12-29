# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V2::Admin::AccountsController do
  path '/api/v2/admin/accounts' do
    get('list accounts') do
      tags 'Api', 'V2', 'Admin', 'Accounts'
      operationId 'v2AdminAccountsListAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

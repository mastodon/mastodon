# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::Lists::AccountsController do
  path '/api/v1/lists/{list_id}/accounts' do
    # You'll want to customize the parameter types...
    parameter name: 'list_id', in: :path, type: :string, description: 'list_id'

    get('show account') do
      tags 'Api', 'V1', 'Lists', 'Accounts'
      operationId 'v1ListsAccountsShowAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:list_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete account') do
      tags 'Api', 'V1', 'Lists', 'Accounts'
      operationId 'v1ListsAccountsDeleteAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:list_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    post('create account') do
      tags 'Api', 'V1', 'Lists', 'Accounts'
      operationId 'v1ListsAccountsCreateAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:list_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

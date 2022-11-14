# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::LookupController, type: :request do
  path '/api/v1/accounts/lookup' do
    get('show lookup') do
      tags 'Api', 'V1', 'Accounts', 'Lookup'
      operationId 'v1AccountsLookupShowLookup'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

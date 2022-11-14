# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::SearchController, type: :request do
  path '/api/v1/accounts/search' do
    get('show search') do
      tags 'Api', 'V1', 'Accounts', 'Search'
      operationId 'v1AccountsSearchShowSearch'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

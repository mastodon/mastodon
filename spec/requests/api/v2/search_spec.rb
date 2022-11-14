# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V2::SearchController, type: :request do
  path '/api/v2/search' do
    get('list searches') do
      tags 'Api', 'V2', 'Search'
      operationId 'v2SearchListSearch'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

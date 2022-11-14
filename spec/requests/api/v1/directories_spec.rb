# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::DirectoriesController, type: :request do
  path '/api/v1/directory' do
    get('show directory') do
      tags 'Api', 'V1', 'Directories'
      operationId 'v1DirectoriesShowDirectory'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

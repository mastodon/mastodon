# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::BlocksController, type: :request do
  path '/api/v1/blocks' do
    get('list blocks') do
      tags 'Api', 'V1', 'Blocks'
      operationId 'v1BlocksListBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

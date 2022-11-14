# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::AppsController, type: :request do
  path '/api/v1/apps' do
    post('create app') do
      tags 'Api', 'V1', 'Apps'
      operationId 'v1AppsCreateApp'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

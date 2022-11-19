# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::AppsController, type: :request do
  path '/api/v1/apps' do
    post('create app') do
      tags 'Api', 'V1', 'Apps'
      operationId 'v1AppsCreateApp'
      description 'Create a new application to obtain OAuth2 credentials.'
      rswag_auth_scope
      parameter name: :payload, in: :body, required: true, schema: {
        '$ref': '#/components/schemas/ApplicationRequestBody',
      }

      include_context 'user token auth'

      let(:payload) { { client_name: 'testclient', redirect_uris: 'urn:ietf:wg:oauth:2.0:oob' } }

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

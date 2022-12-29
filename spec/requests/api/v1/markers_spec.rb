# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::MarkersController do
  path '/api/v1/markers' do
    get('list markers') do
      tags 'Api', 'V1', 'Markers'
      operationId 'v1MarkersListMarker'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create marker') do
      tags 'Api', 'V1', 'Markers'
      operationId 'v1MarkersCreateMarker'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

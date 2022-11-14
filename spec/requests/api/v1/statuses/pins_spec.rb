# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Statuses::PinsController, type: :request do
  path '/api/v1/statuses/{status_id}/pin' do
    # You'll want to customize the parameter types...
    parameter name: 'status_id', in: :path, type: :string, description: 'status_id'

    post('create pin') do
      tags 'Api', 'V1', 'Statuses', 'Pins'
      operationId 'v1StatusesPinsCreatePin'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:status_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/statuses/{status_id}/unpin' do
    # You'll want to customize the parameter types...
    parameter name: 'status_id', in: :path, type: :string, description: 'status_id'

    post('delete pin') do
      tags 'Api', 'V1', 'Statuses', 'Pins'
      operationId 'v1StatusesPinsDeletePin'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:status_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

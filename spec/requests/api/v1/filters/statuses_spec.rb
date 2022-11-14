# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Filters::StatusesController, type: :request do
  path '/api/v1/filters/{filter_id}/statuses' do
    # You'll want to customize the parameter types...
    parameter name: 'filter_id', in: :path, type: :string, description: 'filter_id'

    get('list statuses') do
      tags 'Api', 'V1', 'Filters', 'Statuses'
      operationId 'v1FiltersStatusesListStatus'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:filter_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    post('create status') do
      tags 'Api', 'V1', 'Filters', 'Statuses'
      operationId 'v1FiltersStatusesCreateStatus'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:filter_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/filters/statuses/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show status') do
      tags 'Api', 'V1', 'Filters', 'Statuses'
      operationId 'v1FiltersStatusesShowStatus'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete status') do
      tags 'Api', 'V1', 'Filters', 'Statuses'
      operationId 'v1FiltersStatusesDeleteStatus'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

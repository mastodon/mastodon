# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V2::Filters::StatusesController, type: :request do
  path '/api/v2/filters/{filter_id}/statuses' do
    # You'll want to customize the parameter types...
    parameter name: 'filter_id', in: :path, type: :string, description: 'filter_id'

    get('list statuses') do
      tags 'Api', 'V2', 'Filters', 'Statuses'
      operationId 'v2FiltersStatusesListStatus'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:filter_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    post('create status') do
      tags 'Api', 'V2', 'Filters', 'Statuses'
      operationId 'v2FiltersStatusesCreateStatus'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:filter_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v2/filters/statuses/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show status') do
      tags 'Api', 'V2', 'Filters', 'Statuses'
      operationId 'v2FiltersStatusesShowStatus'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete status') do
      tags 'Api', 'V2', 'Filters', 'Statuses'
      operationId 'v2FiltersStatusesDeleteStatus'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

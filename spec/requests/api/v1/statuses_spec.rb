# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::StatusesController, type: :request do
  path '/api/v1/statuses/{id}/context' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('context status') do
      tags 'Api', 'V1', 'Statuses'
      operationId 'v1StatusesContextStatus'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/statuses' do
    post('create status') do
      tags 'Api', 'V1', 'Statuses'
      operationId 'v1StatusesCreateStatus'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/statuses/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show status') do
      tags 'Api', 'V1', 'Statuses'
      operationId 'v1StatusesShowStatus'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update status') do
      tags 'Api', 'V1', 'Statuses'
      operationId 'v1StatusesUpdateStatus'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update status') do
      tags 'Api', 'V1', 'Statuses'
      operationId 'v1StatusesUpdateStatus'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete status') do
      tags 'Api', 'V1', 'Statuses'
      operationId 'v1StatusesDeleteStatus'
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

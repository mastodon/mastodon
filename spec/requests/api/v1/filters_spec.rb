# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::FiltersController do
  path '/api/v1/filters' do
    get('list filters') do
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersListFilter'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create filter') do
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersCreateFilter'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/filters/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show filter') do
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersShowFilter'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update filter') do
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersUpdateFilter'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update filter') do
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersUpdateFilter'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete filter') do
      tags 'Api', 'V1', 'Filters'
      operationId 'v1FiltersDeleteFilter'
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

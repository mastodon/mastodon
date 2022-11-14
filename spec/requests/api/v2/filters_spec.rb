# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V2::FiltersController, type: :request do
  path '/api/v2/filters' do
    get('list filters') do
      tags 'Api', 'V2', 'Filters'
      operationId 'v2FiltersListFilter'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create filter') do
      tags 'Api', 'V2', 'Filters'
      operationId 'v2FiltersCreateFilter'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v2/filters/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show filter') do
      tags 'Api', 'V2', 'Filters'
      operationId 'v2FiltersShowFilter'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update filter') do
      tags 'Api', 'V2', 'Filters'
      operationId 'v2FiltersUpdateFilter'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update filter') do
      tags 'Api', 'V2', 'Filters'
      operationId 'v2FiltersUpdateFilter'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete filter') do
      tags 'Api', 'V2', 'Filters'
      operationId 'v2FiltersDeleteFilter'
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

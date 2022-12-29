# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::ListsController do
  path '/api/v1/lists' do
    get('list lists') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsListList'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create list') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsCreateList'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/lists/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show list') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsShowList'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update list') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsUpdateList'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update list') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsUpdateList'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete list') do
      tags 'Api', 'V1', 'Lists'
      operationId 'v1ListsDeleteList'
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

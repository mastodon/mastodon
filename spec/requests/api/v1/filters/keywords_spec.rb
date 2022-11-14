# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Filters::KeywordsController, type: :request do
  path '/api/v1/filters/{filter_id}/keywords' do
    # You'll want to customize the parameter types...
    parameter name: 'filter_id', in: :path, type: :string, description: 'filter_id'

    get('list keywords') do
      tags 'Api', 'V1', 'Filters', 'Keywords'
      operationId 'v1FiltersKeywordsListKeyword'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:filter_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    post('create keyword') do
      tags 'Api', 'V1', 'Filters', 'Keywords'
      operationId 'v1FiltersKeywordsCreateKeyword'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:filter_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/filters/keywords/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show keyword') do
      tags 'Api', 'V1', 'Filters', 'Keywords'
      operationId 'v1FiltersKeywordsShowKeyword'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update keyword') do
      tags 'Api', 'V1', 'Filters', 'Keywords'
      operationId 'v1FiltersKeywordsUpdateKeyword'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update keyword') do
      tags 'Api', 'V1', 'Filters', 'Keywords'
      operationId 'v1FiltersKeywordsUpdateKeyword'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete keyword') do
      tags 'Api', 'V1', 'Filters', 'Keywords'
      operationId 'v1FiltersKeywordsDeleteKeyword'
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

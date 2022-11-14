# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V2::Filters::KeywordsController, type: :request do
  path '/api/v2/filters/{filter_id}/keywords' do
    # You'll want to customize the parameter types...
    parameter name: 'filter_id', in: :path, type: :string, description: 'filter_id'

    get('list keywords') do
      tags 'Api', 'V2', 'Filters', 'Keywords'
      operationId 'v2FiltersKeywordsListKeyword'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:filter_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    post('create keyword') do
      tags 'Api', 'V2', 'Filters', 'Keywords'
      operationId 'v2FiltersKeywordsCreateKeyword'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:filter_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v2/filters/keywords/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show keyword') do
      tags 'Api', 'V2', 'Filters', 'Keywords'
      operationId 'v2FiltersKeywordsShowKeyword'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update keyword') do
      tags 'Api', 'V2', 'Filters', 'Keywords'
      operationId 'v2FiltersKeywordsUpdateKeyword'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update keyword') do
      tags 'Api', 'V2', 'Filters', 'Keywords'
      operationId 'v2FiltersKeywordsUpdateKeyword'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete keyword') do
      tags 'Api', 'V2', 'Filters', 'Keywords'
      operationId 'v2FiltersKeywordsDeleteKeyword'
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

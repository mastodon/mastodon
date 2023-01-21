# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::SuggestionsController do
  path '/api/v1/suggestions' do
    get('list suggestions') do
      tags 'Api', 'V1', 'Suggestions'
      operationId 'v1SuggestionsListSuggestion'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/suggestions/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    delete('delete suggestion') do
      tags 'Api', 'V1', 'Suggestions'
      operationId 'v1SuggestionsDeleteSuggestion'
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

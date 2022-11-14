# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V2::SuggestionsController, type: :request do
  path '/api/v2/suggestions' do
    get('list suggestions') do
      tags 'Api', 'V2', 'Suggestions'
      operationId 'v2SuggestionsListSuggestion'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

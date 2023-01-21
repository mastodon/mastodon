# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V2::SuggestionsController do
  path '/api/v2/suggestions' do
    get('list suggestions') do
      tags 'Api', 'V2', 'Suggestions'
      operationId 'v2SuggestionsListSuggestion'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

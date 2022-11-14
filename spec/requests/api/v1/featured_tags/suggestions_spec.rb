# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::FeaturedTags::SuggestionsController, type: :request do
  path '/api/v1/featured_tags/suggestions' do
    get('list suggestions') do
      tags 'Api', 'V1', 'FeaturedTags', 'Suggestions'
      operationId 'v1FeaturedtagsSuggestionsListSuggestion'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

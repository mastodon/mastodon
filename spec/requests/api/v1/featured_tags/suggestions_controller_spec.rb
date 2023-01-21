# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::FeaturedTags::SuggestionsController do
  path '/api/v1/featured_tags/suggestions' do
    get('list suggestions') do
      tags 'Api', 'V1', 'FeaturedTags', 'Suggestions'
      operationId 'v1FeaturedtagsSuggestionsListSuggestion'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

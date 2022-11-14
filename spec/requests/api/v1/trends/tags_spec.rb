# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Trends::TagsController, type: :request do
  path '/api/v1/trends' do
    get('list tags') do
      tags 'Api', 'V1', 'Trends', 'Tags'
      operationId 'v1TrendsTagsListTag'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/trends/tags' do
    get('list tags') do
      tags 'Api', 'V1', 'Trends', 'Tags'
      operationId 'v1TrendsTagsListTag'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

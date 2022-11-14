# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::Trends::TagsController, type: :request do
  path '/api/v1/admin/trends/tags' do
    get('list tags') do
      tags 'Api', 'V1', 'Admin', 'Trends', 'Tags'
      operationId 'v1AdminTrendsTagsListTag'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

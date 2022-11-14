# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Statuses::BookmarksController, type: :request do
  path '/api/v1/statuses/{status_id}/bookmark' do
    # You'll want to customize the parameter types...
    parameter name: 'status_id', in: :path, type: :string, description: 'status_id'

    post('create bookmark') do
      tags 'Api', 'V1', 'Statuses', 'Bookmarks'
      operationId 'v1StatusesBookmarksCreateBookmark'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:status_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/statuses/{status_id}/unbookmark' do
    # You'll want to customize the parameter types...
    parameter name: 'status_id', in: :path, type: :string, description: 'status_id'

    post('delete bookmark') do
      tags 'Api', 'V1', 'Statuses', 'Bookmarks'
      operationId 'v1StatusesBookmarksDeleteBookmark'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:status_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::BookmarksController, type: :request do
  path '/api/v1/bookmarks' do
    get('list bookmarks') do
      tags 'Api', 'V1', 'Bookmarks'
      operationId 'v1BookmarksListBookmark'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::FollowedTagsController do
  path '/api/v1/followed_tags' do
    get('list followed_tags') do
      tags 'Api', 'V1', 'FollowedTags'
      operationId 'v1FollowedtagsListFollowedTag'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

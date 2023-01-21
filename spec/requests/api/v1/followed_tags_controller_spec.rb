# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::FollowedTagsController do
  path '/api/v1/followed_tags' do
    get('list followed_tags') do
      description 'View all followed tags'
      tags 'Api', 'V1', 'FollowedTags'
      operationId 'v1FollowedtagsListFollowedTag'
      rswag_auth_scope %w(follow read read:follows)
      rswag_page_params limit_desc: <<~MD
        Maximum number of results to return.  
        Defaults to 100 tags.  
        Max 200 tags.
      MD

      include_context 'user token auth' do
        let(:user_token_scopes) { 'follow read:follows' }
      end
      let!(:tag_follow1) { Fabricate(:tag_follow, account: user.account) }
      let!(:tag_follow2) { Fabricate(:tag_follow, account: user.account) }

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Tag' }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 2).and(
            match_array(
              [
                include({ name: tag_follow1.tag.name }),
                include({ name: tag_follow2.tag.name }),
              ]
            )
          )
        end
      end
    end
  end
end

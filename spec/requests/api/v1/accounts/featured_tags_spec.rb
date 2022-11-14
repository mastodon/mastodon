# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::FeaturedTagsController, type: :request do
  path '/api/v1/accounts/{account_id}/featured_tags' do
    # You'll want to customize the parameter types...
    parameter name: 'account_id', in: :path, type: :string, description: 'account_id'

    get('list featured_tags') do
      tags 'Api', 'V1', 'Accounts', 'FeaturedTags'
      operationId 'v1AccountsFeaturedtagsListFeaturedTag'
      rswag_json_endpoint

      let(:account) { Fabricate(:account) }
      let(:tag) { Fabricate(:tag, name: 'test_tag') }
      let!(:featured_tag) { Fabricate(:featured_tag, account: account, tag: tag, name: 'test_featured_tag') }

      let(:account) { Fabricate(:account) }

      response(200, 'successful') do
        schema type: :array, items: { '$ref': '#/components/schemas/FeaturedTag' }
        let(:account_id) { account.id.to_s }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to match_array(
            include({
              id: featured_tag.id.to_s,
            }.stringify_keys)
          )
        end
      end
    end
  end
end

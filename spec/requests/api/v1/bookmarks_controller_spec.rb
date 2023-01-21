# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::BookmarksController do
  path '/api/v1/bookmarks' do
    get('list bookmarks') do
      tags 'Api', 'V1', 'Bookmarks'
      operationId 'v1BookmarksListBookmark'
      rswag_auth_scope %w(read read:bookmarks)
      parameter name: 'limit', in: :query, type: :integer, required: false,
                description: 'Maximum number of results to return. Defaults to 40.'
      parameter name: 'max_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'
      parameter name: 'min_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'
      parameter name: 'since_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'

      include_context 'user token auth'
      let(:account) { Fabricate(:account) }
      let!(:status) { Fabricate(:status, account: account) }
      let!(:bookmark) { Fabricate(:bookmark, account: user.account, status: status) }

      before do
        user.account.follow!(account)
      end

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Status' }
        rswag_add_examples!
        run_test!
      end
    end
  end
end

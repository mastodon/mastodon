# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::ListsController do
  path '/api/v1/accounts/{account_id}/lists' do
    # You'll want to customize the parameter types...
    parameter name: 'account_id', in: :path, type: :string, description: 'account_id'

    get('list lists') do
      tags 'Api', 'V1', 'Accounts', 'Lists'
      operationId 'v1AccountsListsListList'
      rswag_auth_scope %w(read read:lists)

      let(:account) { Fabricate(:account) }
      include_context 'user token auth' do
        let(:user) { account.user }
      end

      let!(:list) { account.lists.create(title: 'TestList', account: account) }

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/List' }
        let(:account_id) { account.id.to_s }

        rswag_add_examples!

        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to match_array(
            [
              list.slice('title', 'replies_policy').merge(id: list.id.to_s).stringify_keys,
            ]
          )
        end
      end
    end
  end
end

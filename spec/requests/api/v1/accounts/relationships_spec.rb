# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::RelationshipsController, type: :request do
  path '/api/v1/accounts/relationships' do
    get('list relationships') do
      tags 'Api', 'V1', 'Accounts', 'Relationships'
      operationId 'v1AccountsRelationshipsListRelationship'
      rswag_auth_scope %w(read read:follows)
      parameter name: 'id', in: :query, type: :integer,
                description: 'account_ids'

      include_context 'user token auth'
      let!(:account) { Fabricate(:account) }
      let!(:bob) { Fabricate(:account) }
      let!(:jane) { Fabricate(:account) }

      before do
        user.account.follow!(account)
        user.account.follow!(jane)
        jane.follow!(bob)
        bob.follow!(account)
        bob.follow!(user.account)
      end

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Relationship' }
        let('id') { account.id }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to match_array(
            [
              include(
                { id: account.id.to_s }.stringify_keys
              ),
            ]
          )
        end
      end
    end
  end
end

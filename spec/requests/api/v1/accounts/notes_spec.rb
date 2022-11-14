# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::NotesController, type: :request do
  path '/api/v1/accounts/{account_id}/note' do
    # You'll want to customize the parameter types...
    parameter name: 'account_id', in: :path, type: :string, description: 'account_id'

    post('create note') do
      tags 'Api', 'V1', 'Accounts', 'Notes'
      operationId 'v1AccountsNotesCreateNote'
      rswag_auth_scope %w(write write:accounts)
      parameter name: 'note', type: :object, in: :body, required: true, properties: {
        comment: { type: :string },
      }, required: ['comment']

      let(:account) { Fabricate(:account) }
      include_context 'admin token auth' do
        let(:admin_token_scopes) { 'admin:write:accounts write:accounts' }
      end

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:account_id) { account.id }
        let(:note) { { comment: 'testing comment' } }

        rswag_add_examples!

        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, note: 'testing comment' }.stringify_keys
          )
        end
      end
    end
  end
end

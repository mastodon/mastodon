# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::CredentialsController do
  path '/api/v1/accounts/verify_credentials' do
    get('show credential') do
      tags 'Api', 'V1', 'Accounts', 'Credentials'
      operationId 'v1AccountsCredentialsShowCredential'
      rswag_auth_scope(%w(read read:accounts))

      include_context 'user token auth' do
        let(:user_token_scopes) { 'read:accounts' }
      end

      response(200, 'successful') do
        schema type: :object, allOf: [
          { '$ref' => '#/components/schemas/Account' },
          { '$ref' => '#/components/schemas/Credential' },
        ]
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/update_credentials' do
    patch('update credential') do
      tags 'Api', 'V1', 'Accounts', 'Credentials'
      operationId 'v1AccountsCredentialsUpdateCredential'
      rswag_auth_scope(%w(write write:accounts))
      parameter name: :payload, in: :body, required: false, schema: {
        '$ref' => '#/components/requestBodies/v1AccountsUpdateCredentials',
      }

      let(:account) { Fabricate(:account, locked: true, display_name: 'Tester') }
      include_context 'user token auth' do
        let(:user) { account.user }
        let(:user_token_scopes) { 'write:accounts' }
      end

      response(200, 'successful') do
        schema type: :object, allOf: [
          { '$ref' => '#/components/schemas/Account' },
          { '$ref' => '#/components/schemas/Credential' },
        ]
        let(:payload) { { locked: false, display_name: 'Changed' } }

        rswag_add_examples!

        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include({
            id: account.id.to_s,
            locked: false,
            display_name: 'Changed',
          }.stringify_keys)
        end
      end
    end
  end
end

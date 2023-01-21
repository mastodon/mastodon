# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::PinsController do
  path '/api/v1/accounts/{account_id}/pin' do
    # You'll want to customize the parameter types...
    parameter name: 'account_id', in: :path, type: :string, description: 'account_id'

    post('create pin') do
      tags 'Api', 'V1', 'Accounts', 'Pins'
      operationId 'v1AccountsPinsCreatePin'
      rswag_auth_scope %w(write write:accounts)

      include_context 'user token auth'
      let(:account) { Fabricate(:account) }
      before { user.account.follow!(account) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:account_id) { account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, following: true, endorsed: true }.stringify_keys
          )
        end
      end
    end
  end

  path '/api/v1/accounts/{account_id}/unpin' do
    # You'll want to customize the parameter types...
    parameter name: 'account_id', in: :path, type: :string, description: 'account_id'

    post('delete pin') do
      tags 'Api', 'V1', 'Accounts', 'Pins'
      operationId 'v1AccountsPinsDeletePin'
      rswag_auth_scope %w(write write:accounts)

      include_context 'user token auth'
      let(:account) { Fabricate(:account) }
      before do
        user.account.follow!(account)
        AccountPin.create!(account: user.account, target_account: account)
      end

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Relationship'
        let(:account_id) { account.id }

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body(response)
          expect(body).to include(
            { id: account.id.to_s, following: true, endorsed: false }.stringify_keys
          )
        end
      end
    end
  end
end

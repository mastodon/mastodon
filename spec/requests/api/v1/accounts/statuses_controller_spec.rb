# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::StatusesController do
  let(:account) { Fabricate(:account, username: 'bob', domain: 'example.com') }
  let(:other_account) { Fabricate(:account, username: 'jane', domain: 'example.com') }
  let!(:status) { Fabricate(:status, account: account, edited_at: Time.zone.now, language: 'en') }
  let!(:mention) { Fabricate(:mention, account: other_account, status: status) }
  let(:private_status) { Fabricate(:status, account: account, visibility: :private) }
  let!(:pin)           { Fabricate(:status_pin, account: account, status: status) }
  let!(:private_pin)   { Fabricate(:status_pin, account: account, status: private_status) }

  path '/api/v1/accounts/{account_id}/statuses' do
    # You'll want to customize the parameter types...
    parameter name: 'account_id', in: :path, type: :string, description: 'account_id'

    get('list statuses') do
      tags 'Api', 'V1', 'Accounts', 'Statuses'
      operationId 'v1AccountsStatusesListStatus'
      rswag_auth_scope %w(read read:statuses)

      include_context 'user token auth' do
        let(:user_token_scopes) { 'read:statuses' }
      end

      response(200, 'successful') do
        schema type: :array, items: { '$ref': '#/components/schemas/Status' }
        let(:account_id) { account.id }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

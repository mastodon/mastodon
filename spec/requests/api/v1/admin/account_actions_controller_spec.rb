# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::Admin::AccountActionsController do
  path '/api/v1/admin/accounts/{account_id}/action' do
    # You'll want to customize the parameter types...
    parameter name: 'account_id', in: :path, type: :string, description: 'account_id'

    post('create account_action') do
      tags 'Api', 'V1', 'Admin', 'AccountActions'
      operationId 'v1AdminAccountactionsCreateAccountAction'
      description 'Perform an action against an account and log this action in the moderation history.'
      rswag_auth_scope %w(admin:write admin:write:accounts)
      parameter name: :payload, in: :body, required: true, schema: {
        type: :object,
        properties: {
          type: {
            description: 'Type of action to be taken. Enumerable oneOf: none disable silence suspend',
            type: :string,
            enum: %w(none disable silence suspend),
          },
          report_id: {
            type: :string,
            description: 'ID of an associated report that caused this action to be taken',
          },
          warning_preset_id: {
            type: :string,
            description: 'ID of a preset warning',
          },
          text: {
            type: :string,
            description: 'Additional text for clarification of why this action was taken',
          },
          send_email_notification: {
            type: :boolean,
            description: 'Whether an email should be sent to the user with the above information.',
          },
        },
        example: {
          type: 'disable',
          text: 'test action',
          warning_preset_id: '13',
          report_id: '11',
          send_email_notification: false,
        },
      }

      include_context 'admin token auth'
      let(:account) { Fabricate(:account) }

      response(200, 'disable successful') do
        schema type: :object
        let(:account_id) { account.id }
        let(:payload) do
          { type: 'disable', text: 'test action' }
        end
        rswag_add_examples!
        run_test!
      end

      response(403, 'not permitted') do
        schema type: :object, properties: {
          error: { type: :string },
        }
        let(:account_id) { admin.account.id }
        let(:payload) do
          { type: 'suspend', text: 'test action' }
        end
        rswag_add_examples!
        run_test!
      end

      response(404, 'account not found') do
        schema type: :object, properties: {
          error: { type: :string },
        }
        let(:account_id) { '-1' }
        let(:payload) do
          { type: 'disable', text: 'test action' }
        end

        rswag_add_examples!
        run_test!
      end
    end
  end
end

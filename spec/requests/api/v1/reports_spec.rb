# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::ReportsController, type: :request do
  let!(:status) { Fabricate(:status) }
  let(:target_account) { status.account }
  let(:category) { nil }
  let(:forward) { nil }
  let(:rule_ids) { nil }

  path '/api/v1/reports' do
    post('create report') do
      tags 'Api', 'V1', 'Reports'
      operationId 'v1ReportsCreateReport'
      rswag_auth_scope
      parameter name: :payload, in: :body, type: :object, schema: {
        type: :object,
        properties: {
          status_ids: { type: :array, items: { type: :integer } },
          account_id: { type: :integer },
          comment: { type: :string },
          category: { type: :string, nullable: true },
          rule_ids: { type: :array, items: { type: :string }, nullable: true },
          forward: { type: :boolean, nullable: true },
        },
        required: %w(status_ids account_id),
      }

      include_context 'admin token auth' do
        let(:admin_token_scopes) { 'write:reports' }
      end

      response(200, 'successful') do
        schema type: :object, '$ref' => '#/components/schemas/Report'
        let(:payload) do
          {
            status_ids: [status.id],
            account_id: target_account.id,
            comment: 'reasons',
            category: category,
            rule_ids: rule_ids,
            forward: forward,
          }
        end

        rswag_add_examples!(:successful)
        run_test!
      end
    end
  end
end

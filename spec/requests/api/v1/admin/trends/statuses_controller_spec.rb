# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::Trends::StatusesController do
  path '/api/v1/admin/trends/statuses' do
    get('list statuses') do
      tags 'Api', 'V1', 'Admin', 'Trends', 'Statuses'
      operationId 'v1AdminTrendsStatusesListStatus'
      rswag_auth_scope %w(admin:read)
      parameter name: 'limit', in: :query, type: :integer, required: false,
                description: 'Maximum number of results to return. Defaults to 40.'
      parameter name: 'max_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'
      parameter name: 'since_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'
      parameter name: 'offset', in: :query, required: false, type: :integer

      include_context 'admin token auth'

      let(:account) { Fabricate(:account, trendable: true) }
      let(:status) { Fabricate(:status, trendable: true, language: 'en') }
      let!(:status_trend) do
        StatusTrend.create!(status: status, account: account)
      end

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Status' }
        rswag_add_examples!
        run_test!
      end
    end
  end
end

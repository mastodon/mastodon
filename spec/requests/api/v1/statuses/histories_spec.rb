# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Statuses::HistoriesController do
  path '/api/v1/statuses/{status_id}/history' do
    # You'll want to customize the parameter types...
    parameter name: 'status_id', in: :path, type: :string, description: 'status_id'

    get('show history') do
      tags 'Api', 'V1', 'Statuses', 'Histories'
      operationId 'v1StatusesHistoriesShowHistory'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:status_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

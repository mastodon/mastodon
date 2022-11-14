# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Statuses::SourcesController, type: :request do
  path '/api/v1/statuses/{status_id}/source' do
    # You'll want to customize the parameter types...
    parameter name: 'status_id', in: :path, type: :string, description: 'status_id'

    get('show source') do
      tags 'Api', 'V1', 'Statuses', 'Sources'
      operationId 'v1StatusesSourcesShowSource'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:status_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::Statuses::ReblogsController do
  path '/api/v1/statuses/{status_id}/reblog' do
    # You'll want to customize the parameter types...
    parameter name: 'status_id', in: :path, type: :string, description: 'status_id'

    post('create reblog') do
      tags 'Api', 'V1', 'Statuses', 'Reblogs'
      operationId 'v1StatusesReblogsCreateReblog'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:status_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/statuses/{status_id}/unreblog' do
    # You'll want to customize the parameter types...
    parameter name: 'status_id', in: :path, type: :string, description: 'status_id'

    post('delete reblog') do
      tags 'Api', 'V1', 'Statuses', 'Reblogs'
      operationId 'v1StatusesReblogsDeleteReblog'
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

# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Timelines::ListController, type: :request do
  path '/api/v1/timelines/list/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show list') do
      tags 'Api', 'V1', 'Timelines', 'List'
      operationId 'v1TimelinesListShowList'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

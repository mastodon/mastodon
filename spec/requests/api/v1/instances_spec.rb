# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::InstancesController, type: :request do
  path '/api/v1/instance' do
    get('show instance') do
      tags 'Api', 'V1', 'Instances'
      operationId 'v1InstancesShowInstance'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

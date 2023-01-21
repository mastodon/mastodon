# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V2::InstancesController do
  path '/api/v2/instance' do
    get('show instance') do
      tags 'Api', 'V2', 'Instances'
      operationId 'v2InstancesShowInstance'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

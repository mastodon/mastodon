# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::InstancesController do
  path '/api/v1/instance' do
    get('show instance') do
      description <<~MD
        Version history:
        - 1.1.0 added
        - 3.0.0 requires user token if instance is in whitelist mode
        - 3.1.4 added invites_enabled to response
        - 3.4.0 added rules
        - 3.4.2 added configuration
        - 4.0.0 deprecated. added configuration[accounts].
      MD
      tags 'Api', 'V1', 'Instances'
      operationId 'v1InstancesShowInstance'
      deprecated true
      rswag_json_endpoint

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/V1Instance'
        rswag_add_examples!
        run_test!
      end
    end
  end
end

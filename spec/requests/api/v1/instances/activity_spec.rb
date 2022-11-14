# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Instances::ActivityController, type: :request do
  path '/api/v1/instance/activity' do
    get('show activity') do
      tags 'Api', 'V1', 'Instances', 'Activity'
      operationId 'v1InstancesActivityShowActivity'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

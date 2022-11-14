# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Instances::ExtendedDescriptionsController, type: :request do
  path '/api/v1/instance/extended_description' do
    get('show extended_description') do
      tags 'Api', 'V1', 'Instances', 'ExtendedDescriptions'
      operationId 'v1InstancesExtendeddescriptionsShowExtendedDescription'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

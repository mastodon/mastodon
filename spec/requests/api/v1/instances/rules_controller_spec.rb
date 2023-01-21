# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Instances::RulesController do
  path '/api/v1/instance/rules' do
    get('list rules') do
      tags 'Api', 'V1', 'Instances', 'Rules'
      operationId 'v1InstancesRulesListRule'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

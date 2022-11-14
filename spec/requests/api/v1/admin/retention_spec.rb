# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::RetentionController, type: :request do
  path '/api/v1/admin/retention' do
    post('create retention') do
      tags 'Api', 'V1', 'Admin', 'Retention'
      operationId 'v1AdminRetentionCreateRetention'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::RetentionController, type: :request do
  path '/api/v1/admin/retention' do
    post('create retention') do
      tags 'Api', 'V1', 'Admin', 'Retention'
      operationId 'v1AdminRetentionCreateRetention'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

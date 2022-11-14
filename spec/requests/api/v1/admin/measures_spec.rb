# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::MeasuresController, type: :request do
  path '/api/v1/admin/measures' do
    post('create measure') do
      tags 'Api', 'V1', 'Admin', 'Measures'
      operationId 'v1AdminMeasuresCreateMeasure'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

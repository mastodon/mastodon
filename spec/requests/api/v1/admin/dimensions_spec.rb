# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::DimensionsController, type: :request do
  path '/api/v1/admin/dimensions' do
    post('create dimension') do
      tags 'Api', 'V1', 'Admin', 'Dimensions'
      operationId 'v1AdminDimensionsCreateDimension'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

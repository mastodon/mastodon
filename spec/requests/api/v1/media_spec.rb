# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::MediaController, type: :request do
  path '/api/v1/media' do
    post('create medium') do
      tags 'Api', 'V1', 'Media'
      operationId 'v1MediaCreateMedium'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/media/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show medium') do
      tags 'Api', 'V1', 'Media'
      operationId 'v1MediaShowMedium'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update medium') do
      tags 'Api', 'V1', 'Media'
      operationId 'v1MediaUpdateMedium'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update medium') do
      tags 'Api', 'V1', 'Media'
      operationId 'v1MediaUpdateMedium'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

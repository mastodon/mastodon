# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Statuses::MutesController, type: :request do
  path '/api/v1/statuses/{status_id}/mute' do
    # You'll want to customize the parameter types...
    parameter name: 'status_id', in: :path, type: :string, description: 'status_id'

    post('create mute') do
      tags 'Api', 'V1', 'Statuses', 'Mutes'
      operationId 'v1StatusesMutesCreateMute'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:status_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/statuses/{status_id}/unmute' do
    # You'll want to customize the parameter types...
    parameter name: 'status_id', in: :path, type: :string, description: 'status_id'

    post('delete mute') do
      tags 'Api', 'V1', 'Statuses', 'Mutes'
      operationId 'v1StatusesMutesDeleteMute'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:status_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

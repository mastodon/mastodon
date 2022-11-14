# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::ScheduledStatusesController, type: :request do
  path '/api/v1/scheduled_statuses' do
    get('list scheduled_statuses') do
      tags 'Api', 'V1', 'ScheduledStatuses'
      operationId 'v1ScheduledstatusesListScheduledStatus'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/scheduled_statuses/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show scheduled_status') do
      tags 'Api', 'V1', 'ScheduledStatuses'
      operationId 'v1ScheduledstatusesShowScheduledStatus'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update scheduled_status') do
      tags 'Api', 'V1', 'ScheduledStatuses'
      operationId 'v1ScheduledstatusesUpdateScheduledStatus'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update scheduled_status') do
      tags 'Api', 'V1', 'ScheduledStatuses'
      operationId 'v1ScheduledstatusesUpdateScheduledStatus'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete scheduled_status') do
      tags 'Api', 'V1', 'ScheduledStatuses'
      operationId 'v1ScheduledstatusesDeleteScheduledStatus'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

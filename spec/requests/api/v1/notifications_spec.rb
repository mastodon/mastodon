# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::NotificationsController, type: :request do
  path '/api/v1/notifications/clear' do
    post('clear notification') do
      tags 'Api', 'V1', 'Notifications'
      operationId 'v1NotificationsClearNotification'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/notifications/{id}/dismiss' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('dismiss notification') do
      tags 'Api', 'V1', 'Notifications'
      operationId 'v1NotificationsDismissNotification'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/notifications' do
    get('list notifications') do
      tags 'Api', 'V1', 'Notifications'
      operationId 'v1NotificationsListNotification'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/notifications/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show notification') do
      tags 'Api', 'V1', 'Notifications'
      operationId 'v1NotificationsShowNotification'
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

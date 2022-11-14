# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Push::SubscriptionsController, type: :request do
  path '/api/v1/push/subscription' do
    get('show subscription') do
      tags 'Api', 'V1', 'Push', 'Subscriptions'
      operationId 'v1PushSubscriptionsShowSubscription'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    patch('update subscription') do
      tags 'Api', 'V1', 'Push', 'Subscriptions'
      operationId 'v1PushSubscriptionsUpdateSubscription'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    put('update subscription') do
      tags 'Api', 'V1', 'Push', 'Subscriptions'
      operationId 'v1PushSubscriptionsUpdateSubscription'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    delete('delete subscription') do
      tags 'Api', 'V1', 'Push', 'Subscriptions'
      operationId 'v1PushSubscriptionsDeleteSubscription'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create subscription') do
      tags 'Api', 'V1', 'Push', 'Subscriptions'
      operationId 'v1PushSubscriptionsCreateSubscription'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

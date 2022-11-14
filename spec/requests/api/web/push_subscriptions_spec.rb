# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::Web::PushSubscriptionsController, type: :request do
  path '/api/web/push_subscriptions/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('update push_subscription') do
      tags 'Api', 'Web', 'PushSubscriptions'
      operationId 'webPushsubscriptionsUpdatePushSubscription'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/web/push_subscriptions' do
    post('create push_subscription') do
      tags 'Api', 'Web', 'PushSubscriptions'
      operationId 'webPushsubscriptionsCreatePushSubscription'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

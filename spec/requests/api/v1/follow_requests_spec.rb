# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::FollowRequestsController do
  path '/api/v1/follow_requests/{id}/authorize' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('authorize follow_request') do
      tags 'Api', 'V1', 'FollowRequests'
      operationId 'v1FollowrequestsAuthorizeFollowRequest'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/follow_requests/{id}/reject' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('reject follow_request') do
      tags 'Api', 'V1', 'FollowRequests'
      operationId 'v1FollowrequestsRejectFollowRequest'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/follow_requests' do
    get('list follow_requests') do
      tags 'Api', 'V1', 'FollowRequests'
      operationId 'v1FollowrequestsListFollowRequest'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

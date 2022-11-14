# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::AccountsController, type: :request do
  path '/api/v1/accounts/{id}/follow' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('follow account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsFollowAccount'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/{id}/unfollow' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('unfollow account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsUnfollowAccount'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/{id}/remove_from_followers' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('remove_from_followers account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsRemoveFromFollowersAccount'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/{id}/block' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('block account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsBlockAccount'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/{id}/unblock' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('unblock account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsUnblockAccount'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/{id}/mute' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('mute account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsMuteAccount'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/{id}/unmute' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('unmute account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsUnmuteAccount'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts' do
    post('create account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsCreateAccount'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show account') do
      tags 'Api', 'V1', 'Accounts'
      operationId 'v1AccountsShowAccount'
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

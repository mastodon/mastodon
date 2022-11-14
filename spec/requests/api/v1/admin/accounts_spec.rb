# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::AccountsController, type: :request do
  path '/api/v1/admin/accounts/{id}/enable' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('enable account') do
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsEnableAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/accounts/{id}/unsensitive' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('unsensitive account') do
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsUnsensitiveAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/accounts/{id}/unsilence' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('unsilence account') do
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsUnsilenceAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/accounts/{id}/unsuspend' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('unsuspend account') do
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsUnsuspendAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/accounts/{id}/approve' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('approve account') do
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsApproveAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/accounts/{id}/reject' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('reject account') do
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsRejectAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/accounts' do
    get('list accounts') do
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsListAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/accounts/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show account') do
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsShowAccount'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete account') do
      tags 'Api', 'V1', 'Admin', 'Accounts'
      operationId 'v1AdminAccountsDeleteAccount'
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

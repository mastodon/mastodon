# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::ReportsController, type: :request do
  path '/api/v1/admin/reports/{id}/assign_to_self' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('assign_to_self report') do
      tags 'Api', 'V1', 'Admin', 'Reports'
      operationId 'v1AdminReportsAssignToSelfReport'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/reports/{id}/unassign' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('unassign report') do
      tags 'Api', 'V1', 'Admin', 'Reports'
      operationId 'v1AdminReportsUnassignReport'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/reports/{id}/reopen' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('reopen report') do
      tags 'Api', 'V1', 'Admin', 'Reports'
      operationId 'v1AdminReportsReopenReport'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/reports/{id}/resolve' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('resolve report') do
      tags 'Api', 'V1', 'Admin', 'Reports'
      operationId 'v1AdminReportsResolveReport'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/reports' do
    get('list reports') do
      tags 'Api', 'V1', 'Admin', 'Reports'
      operationId 'v1AdminReportsListReport'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/reports/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show report') do
      tags 'Api', 'V1', 'Admin', 'Reports'
      operationId 'v1AdminReportsShowReport'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update report') do
      tags 'Api', 'V1', 'Admin', 'Reports'
      operationId 'v1AdminReportsUpdateReport'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update report') do
      tags 'Api', 'V1', 'Admin', 'Reports'
      operationId 'v1AdminReportsUpdateReport'
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

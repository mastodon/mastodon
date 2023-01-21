# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::Admin::DomainAllowsController do
  path '/api/v1/admin/domain_allows' do
    get('list domain_allows') do
      tags 'Api', 'V1', 'Admin', 'DomainAllows'
      operationId 'v1AdminDomainallowsListDomainAllow'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create domain_allow') do
      tags 'Api', 'V1', 'Admin', 'DomainAllows'
      operationId 'v1AdminDomainallowsCreateDomainAllow'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/domain_allows/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show domain_allow') do
      tags 'Api', 'V1', 'Admin', 'DomainAllows'
      operationId 'v1AdminDomainallowsShowDomainAllow'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete domain_allow') do
      tags 'Api', 'V1', 'Admin', 'DomainAllows'
      operationId 'v1AdminDomainallowsDeleteDomainAllow'
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

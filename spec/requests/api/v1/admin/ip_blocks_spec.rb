# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::IpBlocksController do
  path '/api/v1/admin/ip_blocks' do
    get('list ip_blocks') do
      tags 'Api', 'V1', 'Admin', 'IpBlocks'
      operationId 'v1AdminIpblocksListIpBlock'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create ip_block') do
      tags 'Api', 'V1', 'Admin', 'IpBlocks'
      operationId 'v1AdminIpblocksCreateIpBlock'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/ip_blocks/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show ip_block') do
      tags 'Api', 'V1', 'Admin', 'IpBlocks'
      operationId 'v1AdminIpblocksShowIpBlock'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update ip_block') do
      tags 'Api', 'V1', 'Admin', 'IpBlocks'
      operationId 'v1AdminIpblocksUpdateIpBlock'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update ip_block') do
      tags 'Api', 'V1', 'Admin', 'IpBlocks'
      operationId 'v1AdminIpblocksUpdateIpBlock'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete ip_block') do
      tags 'Api', 'V1', 'Admin', 'IpBlocks'
      operationId 'v1AdminIpblocksDeleteIpBlock'
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

# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::DomainBlocksController, type: :request do
  path '/api/v1/admin/domain_blocks' do
    get('list domain_blocks') do
      tags 'Api', 'V1', 'Admin', 'DomainBlocks'
      operationId 'v1AdminDomainblocksListDomainBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create domain_block') do
      tags 'Api', 'V1', 'Admin', 'DomainBlocks'
      operationId 'v1AdminDomainblocksCreateDomainBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/domain_blocks/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show domain_block') do
      tags 'Api', 'V1', 'Admin', 'DomainBlocks'
      operationId 'v1AdminDomainblocksShowDomainBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    patch('update domain_block') do
      tags 'Api', 'V1', 'Admin', 'DomainBlocks'
      operationId 'v1AdminDomainblocksUpdateDomainBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    put('update domain_block') do
      tags 'Api', 'V1', 'Admin', 'DomainBlocks'
      operationId 'v1AdminDomainblocksUpdateDomainBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete domain_block') do
      tags 'Api', 'V1', 'Admin', 'DomainBlocks'
      operationId 'v1AdminDomainblocksDeleteDomainBlock'
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

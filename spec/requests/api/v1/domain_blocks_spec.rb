# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::DomainBlocksController do
  path '/api/v1/domain_blocks' do
    get('show domain_block') do
      tags 'Api', 'V1', 'DomainBlocks'
      operationId 'v1DomainblocksShowDomainBlock'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    delete('delete domain_block') do
      tags 'Api', 'V1', 'DomainBlocks'
      operationId 'v1DomainblocksDeleteDomainBlock'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create domain_block') do
      tags 'Api', 'V1', 'DomainBlocks'
      operationId 'v1DomainblocksCreateDomainBlock'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

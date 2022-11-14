# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::EmailDomainBlocksController, type: :request do
  path '/api/v1/admin/email_domain_blocks' do
    get('list email_domain_blocks') do
      tags 'Api', 'V1', 'Admin', 'EmailDomainBlocks'
      operationId 'v1AdminEmaildomainblocksListEmailDomainBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create email_domain_block') do
      tags 'Api', 'V1', 'Admin', 'EmailDomainBlocks'
      operationId 'v1AdminEmaildomainblocksCreateEmailDomainBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/email_domain_blocks/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show email_domain_block') do
      tags 'Api', 'V1', 'Admin', 'EmailDomainBlocks'
      operationId 'v1AdminEmaildomainblocksShowEmailDomainBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete email_domain_block') do
      tags 'Api', 'V1', 'Admin', 'EmailDomainBlocks'
      operationId 'v1AdminEmaildomainblocksDeleteEmailDomainBlock'
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

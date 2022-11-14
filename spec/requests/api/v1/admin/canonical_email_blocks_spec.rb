# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Admin::CanonicalEmailBlocksController, type: :request do
  path '/api/v1/admin/canonical_email_blocks/test' do
    post('test canonical_email_block') do
      tags 'Api', 'V1', 'Admin', 'CanonicalEmailBlocks'
      operationId 'v1AdminCanonicalemailblocksTestCanonicalEmailBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/canonical_email_blocks' do
    get('list canonical_email_blocks') do
      tags 'Api', 'V1', 'Admin', 'CanonicalEmailBlocks'
      operationId 'v1AdminCanonicalemailblocksListCanonicalEmailBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end

    post('create canonical_email_block') do
      tags 'Api', 'V1', 'Admin', 'CanonicalEmailBlocks'
      operationId 'v1AdminCanonicalemailblocksCreateCanonicalEmailBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/admin/canonical_email_blocks/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show canonical_email_block') do
      tags 'Api', 'V1', 'Admin', 'CanonicalEmailBlocks'
      operationId 'v1AdminCanonicalemailblocksShowCanonicalEmailBlock'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end

    delete('delete canonical_email_block') do
      tags 'Api', 'V1', 'Admin', 'CanonicalEmailBlocks'
      operationId 'v1AdminCanonicalemailblocksDeleteCanonicalEmailBlock'
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

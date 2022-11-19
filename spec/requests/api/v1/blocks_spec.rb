# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::BlocksController, type: :request do
  path '/api/v1/blocks' do
    get('list blocks') do
      tags 'Api', 'V1', 'Blocks'
      operationId 'v1BlocksListBlock'
      description 'View your blocks. See also accounts/:id/{block,unblock}'
      rswag_auth_scope %w(follow read read:blocks)
      parameter name: 'limit', in: :query, type: :integer, required: false,
                description: 'Maximum number of results to return. Defaults to 40.'
      parameter name: 'max_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'
      parameter name: 'since_id', in: :query, required: false, type: :string,
                description: 'Internal parameter. Use HTTP Link header for pagination.'

      include_context 'user token auth'
      let!(:accounts) do
        3.times.map { Fabricate(:account) }
      end

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Account' }
        let(:limit) { 2 }
        before { accounts.map { |account| user.account.block!(account) } }
        rswag_add_examples!
        run_test!
      end
    end
  end
end

# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Instances::DomainBlocksController do
  path '/api/v1/instance/domain_blocks' do
    get('list domain_blocks') do
      tags 'Api', 'V1', 'Instances', 'DomainBlocks'
      operationId 'v1InstancesDomainblocksListDomainBlock'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

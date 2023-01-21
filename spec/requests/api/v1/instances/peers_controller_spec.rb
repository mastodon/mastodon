# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::Instances::PeersController do
  path '/api/v1/instance/peers' do
    get('list peers') do
      tags 'Api', 'V1', 'Instances', 'Peers'
      operationId 'v1InstancesPeersListPeer'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

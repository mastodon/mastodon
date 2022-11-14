# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::PinsController, type: :request do
  path '/api/v1/accounts/{account_id}/pin' do
    # You'll want to customize the parameter types...
    parameter name: 'account_id', in: :path, type: :string, description: 'account_id'

    post('create pin') do
      tags 'Api', 'V1', 'Accounts', 'Pins'
      operationId 'v1AccountsPinsCreatePin'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:account_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/{account_id}/unpin' do
    # You'll want to customize the parameter types...
    parameter name: 'account_id', in: :path, type: :string, description: 'account_id'

    post('delete pin') do
      tags 'Api', 'V1', 'Accounts', 'Pins'
      operationId 'v1AccountsPinsDeletePin'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        let(:account_id) { '123' }

        rswag_add_examples!
        run_test!
      end
    end
  end
end

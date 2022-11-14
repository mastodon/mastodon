# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Accounts::CredentialsController, type: :request do
  path '/api/v1/accounts/verify_credentials' do
    get('show credential') do
      tags 'Api', 'V1', 'Accounts', 'Credentials'
      operationId 'v1AccountsCredentialsShowCredential'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/accounts/update_credentials' do
    patch('update credential') do
      tags 'Api', 'V1', 'Accounts', 'Credentials'
      operationId 'v1AccountsCredentialsUpdateCredential'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

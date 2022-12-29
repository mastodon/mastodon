# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Apps::CredentialsController do
  path '/api/v1/apps/verify_credentials' do
    get('show credential') do
      tags 'Api', 'V1', 'Apps', 'Credentials'
      operationId 'v1AppsCredentialsShowCredential'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

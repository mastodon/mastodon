# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V2::MediaController do
  path '/api/v2/media' do
    post('create medium') do
      tags 'Api', 'V2', 'Media'
      operationId 'v2MediaCreateMedium'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

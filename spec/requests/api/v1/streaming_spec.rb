# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::StreamingController, type: :request do
  path '/api/v1/streaming' do
    get('list streamings') do
      tags 'Api', 'V1', 'Streaming'
      operationId 'v1StreamingListStreaming'
      rswag_bearer_auth

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

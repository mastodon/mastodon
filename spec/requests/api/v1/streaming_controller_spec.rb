# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::StreamingController do
  path '/api/v1/streaming' do
    get('list streamings') do
      tags 'Api', 'V1', 'Streaming'
      operationId 'v1StreamingListStreaming'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

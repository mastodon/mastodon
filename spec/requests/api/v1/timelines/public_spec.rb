# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::Timelines::PublicController, type: :request do
  path '/api/v1/timelines/public' do
    get('show public') do
      tags 'Api', 'V1', 'Timelines', 'Public'
      operationId 'v1TimelinesPublicShowPublic'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end

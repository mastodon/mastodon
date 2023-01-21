# frozen_string_literal: true
# TODO: implement rswag spec from generated scafold

require 'swagger_helper'

RSpec.describe Api::V1::Timelines::HomeController do
  path '/api/v1/timelines/home' do
    get('show home') do
      tags 'Api', 'V1', 'Timelines', 'Home'
      operationId 'v1TimelinesHomeShowHome'
      rswag_auth_scope

      include_context 'user token auth'

      response(200, 'successful') do
        rswag_add_examples!
        run_test!
      end
    end
  end
end
